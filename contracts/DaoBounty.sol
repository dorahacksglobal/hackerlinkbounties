// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

/// @dev A simple contract for issuing bounties on Ethereum paying in ETH, or ERC20 tokens, has no approval mechanism,
///      so anyone can issue a bounty. It supports multiple bounties, each with a different token, multiple
///      contributors and multiple fulfillers.
/// @author Noodles <noodles@dorahacks.com>
contract DaoBounty is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    /*
     * Structs
     */

    struct Bounty {
        address payable issuer; // Who have complete control over the bounty
        address tokenAddress; // The address of the token associated with the bounty (0 for ETH, others for ERC20)
        uint256 balance; // The number of tokens which the bounty is able to pay out
        bool hasPaidOut; // A boolean storing whether or not the bounty has paid out all its tokens
        Record[] contributions; // An array of Contributions which store the contributions which have been made to the bounty
        Record[] fulfillments; // An array of fulfillments which store the token amount which have been given
    }

    struct Record {
        address payable account; // The address of the individual who contributed or fulfilled the bounty
        uint256 amount; // The amount of tokens which have been contributed or given
    }

    /*
     * Storage
     */

    uint256 public numBounties; // An integer storing the total number of bounties in the contract
    mapping(address => bool) public tokenWhitelist; // A mapping of ERC20 token addresses to whether or not they are whitelisted
    mapping(uint256 => Bounty) public bounties; // A mapping of bountyIDs to bounties

    bool public callStarted; // Ensures mutex for the entire contract

    /*
     * Modifiers
     */

    modifier onlyIssuer(uint256 _bountyId) {
        require(
            msg.sender == bounties[_bountyId].issuer,
            "Only the issuer can perform this action"
        );
        _;
    }

    modifier hasNotPaidOut(uint256 _bountyId) {
        require(
            !bounties[_bountyId].hasPaidOut,
            "Bounty has already been paid out"
        );
        _;
    }

    modifier callNotStarted() {
        require(!callStarted, "Contract is currently being called");
        callStarted = true;
        _;
        callStarted = false;
    }

    modifier validateBountyArrayIndex(uint256 _index) {
        require(_index < numBounties, "Index out of bounties array bounds");
        _;
    }

    /*
     * Public functions
     */

    /// @dev follow the pattern of OpenZeppelin's upgradeable contracts, define initialize() instead of constructor()
    function initialize() public initializer {
        __Ownable_init();
    }

    /// @dev issueBounty(): creates a new bounty
    /// @param _tokenAddress the address of the token which will be used for the bounty
    function issueBounty(address _tokenAddress) public returns (uint256) {
        require(
            _tokenAddress == address(0) ||
                tokenWhitelist[_tokenAddress] == true,
            "Token is not whitelisted"
        ); // Ensures a bounty can only be issued with a valid token address

        uint256 bountyId = numBounties; // The next bounty's index will always equal the number of existing bounties

        Bounty storage newBounty = bounties[bountyId];
        newBounty.issuer = payable(msg.sender);

        newBounty.tokenAddress = _tokenAddress;

        numBounties = numBounties.add(1); // Increments the number of bounties, since a new one has just been added

        emit BountyIssued(bountyId, newBounty.issuer, _tokenAddress);

        return (bountyId);
    }

    /// @dev issueAndContribute(): creates a new bounty and adds a contribution
    /// @param _depositAmount the amount of tokens being deposited to the bounty, which will create a new contribution to the bounty
    function issueAndContribute(address _tokenAddress, uint256 _depositAmount)
        public
        payable
        returns (uint256)
    {
        uint256 bountyId = issueBounty(_tokenAddress);

        contribute(bountyId, _depositAmount);

        return (bountyId);
    }

    /// @dev contribute(): Allows users to contribute tokens to a given bounty.
    ///                    Contributing merits no privelages to administer the
    ///                    funds in the bounty or accept submissions. Contributions
    ///                    are NOT refundable, so please be careful!
    /// @param _bountyId the index of the bounty
    /// @param _depositAmount the amount of tokens being contributed
    function contribute(uint256 _bountyId, uint256 _depositAmount)
        public
        payable
        validateBountyArrayIndex(_bountyId)
        hasNotPaidOut(_bountyId)
        callNotStarted
    {
        require(_depositAmount > 0, "Deposit amount should not be zero"); // Contributions of 0 tokens or token ID 0 should fail

        if (bounties[_bountyId].tokenAddress == address(0)) {
            require(
                msg.value == _depositAmount,
                "Deposit amount should match the amount of ETH sent"
            );
        } else {
            require(
                msg.value == 0,
                "Bounty can't be issued in both ETH and ERC20"
            ); // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
            require(
                IERC20Upgradeable(bounties[_bountyId].tokenAddress)
                    .transferFrom(msg.sender, address(this), _depositAmount),
                "Failed to transfer tokens"
            );
        }

        bounties[_bountyId].contributions.push(
            Record(payable(msg.sender), _depositAmount)
        ); // Adds the contribution to the bounty

        bounties[_bountyId].balance = bounties[_bountyId].balance.add(
            _depositAmount
        ); // Increments the balance of the bounty

        emit ContributionAdded(
            _bountyId,
            bounties[_bountyId].contributions.length - 1, // The new contributionId
            msg.sender,
            _depositAmount
        );
    }

    /// @dev acceptFulfillment(): Allows issuer to accept a given submission
    /// @param _bountyId the index of the bounty
    /// @param _fulfillers the array of fulfillers to be accepted
    /// @param _tokenAmounts the array of token amounts which will be paid to the
    ///                      fulfillers, whose length should equal the length of the
    ///                      _fulfillers array of the submission.
    function acceptFulfillment(
        uint256 _bountyId,
        address payable[] memory _fulfillers,
        uint256[] memory _tokenAmounts
    )
        public
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_bountyId)
        callNotStarted
    {
        require(
            _tokenAmounts.length == _fulfillers.length,
            "Length of arrays should be equal"
        ); // Each fulfiller should get paid some amount of tokens (this can be 0)

        for (uint256 i = 0; i < _fulfillers.length; i++) {
            if (_tokenAmounts[i] > 0) {
                transferTokens(_bountyId, _fulfillers[i], _tokenAmounts[i]); // Transfers the tokens to the fulfiller

                bounties[_bountyId].fulfillments.push(
                    Record(_fulfillers[i], _tokenAmounts[i])
                ); // Adds the fulfillment to the bounty
            }
        }

        if (bounties[_bountyId].balance == 0) {
            bounties[_bountyId].hasPaidOut = true;
            emit BountyPaiedOut(_bountyId);
        }

        emit FulfillmentAccepted(_bountyId, _fulfillers, _tokenAmounts);
    }

    /// @dev changeBounty(): Allows issuer to change the bounty
    /// @param _bountyId the index of the bounty
    /// @param _issuer the new address who will be the issuer of the bounty
    function changeBounty(uint256 _bountyId, address payable _issuer)
        public
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_bountyId)
    {
        bounties[_bountyId].issuer = _issuer;
        emit BountyChanged(_bountyId, _issuer);
    }

    /// @dev getBounty(): Returns the details of the bounty
    /// @param _bountyId the index of the bounty
    /// @return Returns a tuple for the bounty
    function getBounty(uint256 _bountyId)
        external
        view
        returns (Bounty memory)
    {
        return bounties[_bountyId];
    }

    /// @dev addToWhitelist(): Add particular address onto whitelist
    /// @param _tokenAddress the address of the token which will be used for the bounty
    function addToWhitelist(address _tokenAddress) public onlyOwner {
        tokenWhitelist[_tokenAddress] = true;
        emit AddedToWhitelist(_tokenAddress);
    }

    /// @dev removeFromWhitelist(): Eliminate particular address from whitelist
    /// @param _tokenAddress the address of the token
    function removeFromWhitelist(address _tokenAddress) public onlyOwner {
        tokenWhitelist[_tokenAddress] = false;
        emit RemovedFromWhitelist(_tokenAddress);
    }

    /*
     * Internal functions
     */

    function transferTokens(
        uint256 _bountyId,
        address payable _to,
        uint256 _amount
    ) internal {
        require(_amount > 0, "Amount should not be zero"); // Sending 0 tokens should throw
        require(
            bounties[_bountyId].balance >= _amount,
            "Amount should not be greater than bounty balance"
        );

        bounties[_bountyId].balance = bounties[_bountyId].balance.sub(_amount);

        if (bounties[_bountyId].tokenAddress == address(0)) {
            _to.transfer(_amount);
        } else {
            require(
                IERC20Upgradeable(bounties[_bountyId].tokenAddress).transfer(
                    _to,
                    _amount
                )
            );
        }
    }

    /*
     * Events
     */

    event BountyIssued(
        uint256 indexed _bountyId,
        address payable _issuer,
        address _tokenAddress
    );

    event BountyPaiedOut(uint256 indexed _bountyId);

    event ContributionAdded(
        uint256 indexed _bountyId,
        uint256 _contributionId,
        address _contributor,
        uint256 _amount
    );

    event FulfillmentAccepted(
        uint256 indexed _bountyId,
        address payable[] _fulfillers,
        uint256[] _tokenAmounts
    );

    event BountyChanged(uint256 indexed _bountyId, address payable _newIssuer);

    event AddedToWhitelist(address _tokenAddress);

    event RemovedFromWhitelist(address _tokenAddress);
}
