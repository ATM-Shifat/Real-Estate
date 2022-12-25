import classNames from "classnames";
import useSigner from "state/signer";
import CreationForm, { CreationValues } from "./CreationForm";

const CreationPage = () => {
  const {signer} = useSigner();

  const onSubmit = async (values: CreationValues) => {
    console.log(values);
  };

  return (
    <div
      className={classNames("flex h-full w-full flex-col", {
        "items-center justify-center": !signer,
      })}
    >
      {signer ? <CreationForm onSubmit={onSubmit} /> : "Connect your wallet"}
    </div>
  );
};

export default CreationPage;
