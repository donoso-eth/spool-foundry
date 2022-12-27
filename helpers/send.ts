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

//check();

// anvil --fork-block-number 7850256 -f https://goerli.infura.io/v3/1e43f3d31eea4244bf25ed4c13bfde0e
