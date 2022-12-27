let script = `forge 
verify-contract 
--chain-id 5 
--num-of-optimizations 1000 
--watch  
--compiler-version v0.8.17+commit.8df45f5f 
0x74059411c65Fbe548575e60A67A10E4aDffF2D6c 
src/Pool-V1.sol:PoolV1 
--flatten`