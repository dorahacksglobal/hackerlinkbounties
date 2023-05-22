# Aptos Dao Bounty

## 1. Initialize local account

```bash
aptos init
```

displays:

```text
➜  hackerlinkbounties git:(aptos-dao-bounty) aptos init
Configuring for profile default
Choose network from [devnet, testnet, mainnet, local, custom | defaults to devnet]
devnet
Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]

No key given, generating key...
Account xxx doesn't exist, creating it and funding it with 100000000 Octas
Account xxx funded successfully

---
Aptos CLI is now set up for account xxx as profile default!  Run `aptos --help` for more information about commands
```

## 2. Compile

```bash
aptos move compile --named-addresses dao_bounty=default
```

## 3. Test

```bash
aptos move test --named-addresses dao_bounty=default
```

## 4. Deploy

```bash
aptos move publish --named-addresses dao_bounty=default
```

## 5. Run

### 5.1 Initialize contract

```bash
aptos move run \
   --function-id default::bounty::initialize \
   --args address:0xd00476a0176fbe1f1940f315c685615cc36da1056634e6123799debab99e2007
```

### 5.2 Issue a new bounty and contribute to it

```bash
aptos move run \
   --function-id default::bounty::issue_and_contribute \
   --args u64:100000 \
   --type-args 0x1::aptos_coin::AptosCoin
```

### 5.3 Accept Fulfillments by issuer

```bash
aptos move run \
   --function-id default::bounty::accept_fulfillment \
   --args u64:0 'vector<address>:0x3e5681e9fc7a3cbd2641e0466db705505f51347666de582313e00e644787b9a7' 'vector<u64>:50000' \
   --type-args 0x1::aptos_coin::AptosCoin
```
