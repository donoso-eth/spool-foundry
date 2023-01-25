import * as dotenv from 'dotenv';
dotenv.config();

export const deploy = async (contract:string) => {
    let priv_key =  process.env['PRIV_KEY'];
    console.log(priv_key);

    const { spawn } = await import("child_process");
    const childProcess = spawn('forge', ['create','src/Counter.sol:Counter',`--private-key=${priv_key}`], {
        stdio: "inherit",
      });
    

    childProcess.once("close", (status) => {
        childProcess.removeAllListeners("error");
  
        if (status === 0) {
        console.log('ok')
        } else {
            console.log('error')
        }
        


      });
  
      childProcess.once("error", (_status) => {
        childProcess.removeAllListeners("close");
        console.log('error')
      });

}

// ALCHEMY_ID_MUMBAI=P2lEQkjFdNjdN0M_mpZKB8r3fAa2M0vT
// ALCHEMY_ID_POLYGON=https://polygon-mainnet.g.alchemy.com/v2/HF4Mmimsk9XWO446jjrFyt2xEzXier-f

//anvil --fork-block-number  blockNumber: 38517183 -f https://polygon-mainnet.g.alchemy.com/v2/HF4Mmimsk9XWO446jjrFyt2xEzXier-f
//forge test --fork-url http://127.0.0.1:8545 -vv --match-test testFuzzDeposit