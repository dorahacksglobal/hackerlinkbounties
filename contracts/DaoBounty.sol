// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @dev A contract for issuing bounties on Ethereum paying in ETH, or ERC20 tokens
/// @author Noodles <noodles@dorahacks.com>
contract DaoBounty is Ownable {
    using SafeMath for uint256;

    /*
     * Structs
     */

    struct Bounty {
        address payable issuer; // Who have complete control over the bounty
        address token; // The address of the token associated with the bounty (should be disregarded if the tokenVersion is 0)
        uint256 tokenVersion; // The version of the token being used for the bounty (0 for ETH, 20 for ERC20)
        uint256 balance; // The number of tokens which the bounty is able to pay out
        bool hasPaidOut; // A boolean storing whether or not the bounty has paid out all its tokens
        Contribution[] contributions; // An array of Contributions which store the contributions which have been made to the bounty
    }

    struct Contribution {
        address payable contributor; // The address of the individual who contributed
        uint256 amount; // The amount of tokens the user contributed
    }

    /*
     * Storage
     */

    uint256 public numBounties; // An integer storing the total number of bounties in the contract
    mapping(uint256 => Bounty) public bounties; // A mapping of bountyIDs to bounties

    bool public callStarted; // Ensures mutex for the entire contract

    /*
     * Modifiers
     */

    modifier senderIsValid(address _sender) {
        require(
            msg.sender == _sender || msg.sender == owner(),
            "Sender is not valid"
        );
        _;
    }

    modifier onlyIssuer(address _sender, uint256 _bountyId) {
        require(_sender == bounties[_bountyId].issuer);
        _;
    }

    modifier hasNotPaidOut(uint256 _bountyId) {
        require(!bounties[_bountyId].hasPaidOut);
        _;
    }

    modifier callNotStarted() {
        require(!callStarted);
        callStarted = true;
        _;
        callStarted = false;
    }

    modifier validateBountyArrayIndex(uint256 _index) {
        require(_index < numBounties);
        _;
    }

    /*
     * Public functions
     */

    /// @dev issueBounty(): creates a new bounty
    /// @param _sender the sender of the transaction issuing the bounty (should be the same as msg.sender unless the txn is called by the owner)
    /// @param _issuer who will be the issuer of the bounty
    /// @param _token the address of the token which will be used for the bounty
    /// @param _tokenVersion the version of the token being used for the bounty (0 for ETH, 20 for ERC20)
    function issueBounty(
        address payable _sender,
        address payable _issuer,
        address _token,
        uint256 _tokenVersion
    ) public senderIsValid(_sender) returns (uint256) {
        require(_tokenVersion == 0 || _tokenVersion == 20); // Ensures a bounty can only be issued with a valid token version

        uint256 bountyId = numBounties; // The next bounty's index will always equal the number of existing bounties

        Bounty storage newBounty = bounties[bountyId];
        newBounty.issuer = _issuer;
        newBounty.tokenVersion = _tokenVersion;

        if (_tokenVersion != 0) {
            newBounty.token = _token;
        }

        numBounties = numBounties.add(1); // Increments the number of bounties, since a new one has just been added

        emit BountyIssued(bountyId, _sender, _issuer, _token, _tokenVersion);

        return (bountyId);
    }

    /// @param _depositAmount the amount of tokens being deposited to the bounty, which will create a new contribution to the bounty
    function issueAndContribute(
        address payable _sender,
        address payable _issuer,
        address _token,
        uint256 _tokenVersion,
        uint256 _depositAmount
    ) public payable returns (uint256) {
        uint256 bountyId = issueBounty(_sender, _issuer, _token, _tokenVersion);

        contribute(_sender, bountyId, _depositAmount);

        return (bountyId);
    }

    /// @dev contribute(): Allows users to contribute tokens to a given bounty.
    ///                    Contributing merits no privelages to administer the
    ///                    funds in the bounty or accept submissions. Contributions
    ///                    are NOT refundable , so please be careful!
    /// @param _sender the sender of the transaction issuing the bounty (should be the same as msg.sender unless the txn is called by the owner)
    /// @param _bountyId the index of the bounty
    /// @param _amount the amount of tokens being contributed
    function contribute(
        address payable _sender,
        uint256 _bountyId,
        uint256 _amount
    )
        public
        payable
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        hasNotPaidOut(_bountyId)
        callNotStarted
    {
        require(_amount > 0); // Contributions of 0 tokens or token ID 0 should fail

        bounties[_bountyId].contributions.push(Contribution(_sender, _amount)); // Adds the contribution to the bounty

        if (bounties[_bountyId].tokenVersion == 0) {
            require(msg.value == _amount);
            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount
            ); // Increments the balance of the bounty
        } else if (bounties[_bountyId].tokenVersion == 20) {
            require(msg.value == 0); // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
            require(
                IERC20(bounties[_bountyId].token).transferFrom(
                    _sender,
                    address(this),
                    _amount
                )
            );

            bounties[_bountyId].balance = bounties[_bountyId].balance.add(
                _amount
            ); // Increments the balance of the bounty
        } else {
            revert();
        }

        emit ContributionAdded(
            _bountyId,
            bounties[_bountyId].contributions.length - 1, // The new contributionId
            _sender,
            _amount
        );
    }

    /// @dev acceptFulfillment(): Allows issuer to accept a given submission
    /// @param _sender the sender of the transaction issuing the bounty (should be the same as msg.sender unless the txn is called by the owner)
    /// @param _bountyId the index of the bounty
    /// @param _fulfillers the array of fulfillers to be accepted
    /// @param _tokenAmounts the array of token amounts which will be paid to the
    ///                      fulfillers, whose length should equal the length of the
    ///                      _fulfillers array of the submission.
    function acceptFulfillment(
        address _sender,
        uint256 _bountyId,
        address payable[] memory _fulfillers,
        uint256[] memory _tokenAmounts
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_sender, _bountyId)
        callNotStarted
    {
        require(_tokenAmounts.length == _fulfillers.length); // Each fulfiller should get paid some amount of tokens (this can be 0)

        for (uint256 i = 0; i < _fulfillers.length; i++) {
            if (_tokenAmounts[i] > 0) {
                // for each fulfiller associated with the submission
                transferTokens(_bountyId, _fulfillers[i], _tokenAmounts[i]);
            }
        }

        if (bounties[_bountyId].balance == 0) {
            bounties[_bountyId].hasPaidOut = true;
        }

        emit FulfillmentAccepted(
            _sender,
            _bountyId,
            _fulfillers,
            _tokenAmounts
        );
    }

    /// @dev changeBounty(): Allows any of the issuers to change the bounty
    /// @param _sender the sender of the transaction issuing the bounty (should be the same as msg.sender unless the txn is called by the owner)
    /// @param _bountyId the index of the bounty
    /// @param _issuer the new array of addresses who will be the issuers of the bounty
    function changeBounty(
        address _sender,
        uint256 _bountyId,
        address payable _issuer
    )
        public
        senderIsValid(_sender)
        validateBountyArrayIndex(_bountyId)
        onlyIssuer(_sender, _bountyId)
    {
        bounties[_bountyId].issuer = _issuer;
        emit BountyChanged(_bountyId, _sender, _issuer);
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

    function transferTokens(
        uint256 _bountyId,
        address payable _to,
        uint256 _amount
    ) internal {
        if (bounties[_bountyId].tokenVersion == 0) {
            require(_amount > 0); // Sending 0 tokens should throw
            require(bounties[_bountyId].balance >= _amount);

            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount
            );

            _to.transfer(_amount);
        } else if (bounties[_bountyId].tokenVersion == 20) {
            require(_amount > 0); // Sending 0 tokens should throw
            require(bounties[_bountyId].balance >= _amount);

            bounties[_bountyId].balance = bounties[_bountyId].balance.sub(
                _amount
            );

            require(IERC20(bounties[_bountyId].token).transfer(_to, _amount));
        } else {
            revert();
        }
    }

    /*
     * Events
     */

    event BountyIssued(
        uint256 _bountyId,
        address payable _creator,
        address payable _issuer,
        address _token,
        uint256 _tokenVersion
    );

    event ContributionAdded(
        uint256 _bountyId,
        uint256 _contributionId,
        address payable _contributor,
        uint256 _amount
    );

    event BountyChanged(
        uint256 _bountyId,
        address _changer,
        address payable _issuer
    );

    event FulfillmentAccepted(
        address _approver,
        uint256 _bountyId,
        address payable[] _fulfillers,
        uint256[] _tokenAmounts
    );
}
