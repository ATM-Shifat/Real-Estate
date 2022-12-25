import { ReactNode, createContext, useContext, useState, useEffect } from "react";
import {JsonRpcSigner, Web3Provider} from "@ethersproject/providers";
import Web3Modal from "web3modal";

type SignerContextType = {
    signer?: JsonRpcSigner;
    address?: string;
    loading: boolean;
    connectWallet: () => Promise<void>;
};

const SignerContext  =createContext<SignerContextType>({} as any);

const useSigner = () => useContext(SignerContext);

export const SignerProvider = ({children}:{children: ReactNode}) => {
    const [signer, setSigner] = useState<JsonRpcSigner>();
    const [address, setAddress] = useState<string>();
    const [loading, setLoading] = useState(false);


    useEffect(()=>{
      const web3Modal = new Web3Modal();

      if(web3Modal.cachedProvider)connectWallet();
      
    }, []);

    const connectWallet = async () => {
      setLoading(true);
      try{
        const web3Modal = new Web3Modal({cacheProvider: true});
        const instance = await web3Modal.connect();
        const provider = new Web3Provider(instance);
        const signer = provider.getSigner();
        const address = await signer.getAddress();
        setSigner(signer);
        setAddress(address);
        
      } catch(e){
        console.log(e);
      }
      setLoading(false);
    }

    const contextValue = {signer, address, loading, connectWallet};

    return (
        <SignerContext.Provider value={contextValue}>
          {children}
        </SignerContext.Provider>
      );
};

export default useSigner;