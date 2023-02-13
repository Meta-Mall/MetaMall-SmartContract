import { useState } from "react";
import useEth from "../../contexts/EthContext/useEth";
import ContractBtns from "./ContractBtns";
import Desc from "./Desc";
import NoticeNoArtifact from "./NoticeNoArtifact";
import NoticeWrongNetwork from "./NoticeWrongNetwork";

function Demo() {
  const { state } = useEth();
  const [value, setValue] = useState("?");

  const demo =
    <>
      <div className="contract-container">
        <div className="secondary-color">
          {JSON.stringify(value)}
        </div>
        <ContractBtns setValue={setValue} />
      </div>
      <Desc />
    </>;

  return (
    <div className="demo">
      {
        !state.artifact ? <NoticeNoArtifact /> :
          !state.contract ? <NoticeWrongNetwork /> :
            demo
      }
    </div>
  );
}

export default Demo;
