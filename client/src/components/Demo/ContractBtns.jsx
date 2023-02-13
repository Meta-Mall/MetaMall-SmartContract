import { useState } from "react";
import useEth from "../../contexts/EthContext/useEth";
import { parseStore, parseStoreArray } from "../../utils";

function ContractBtns({ setValue }) {
  const { state: { contract, accounts } } = useEth();
  const [inputValue, setInputValue] = useState("");
  const [inputValue2, setInputValue2] = useState("");

  const read = async () => {
    let value = await contract.methods.getAllStores().call({ from: accounts[0] });

    value = value.map(floor => parseStoreArray(floor));

    console.log("value: ", value);
    setValue(JSON.stringify(value));
  };

  const write = async e => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    if (inputValue === "") {
      alert("Please enter a value to write.");
      return;
    }
    const newValue = parseInt(inputValue);
    const newValue2 = parseInt(inputValue2);
    let value = await contract.methods.getStore(newValue, newValue2).call({ from: accounts[0] });
    value = parseStore(value);
    console.log("value: ", value);
  };

  return (
    <div className="btns">

      <button onClick={read}>
        getAll()
      </button>

      <div onClick={write} className="input-btn">
        getStore(<input
          type="text"
          placeholder="floor"
          value={inputValue}
          onChange={(e) => { if (/^\d+$|^$/.test(e.target.value)) { setInputValue(e.target.value); }}}
        />
        <input
          type="text"
          placeholder="index"
          value={inputValue2}
          onChange={(e) => { if (/^\d+$|^$/.test(e.target.value)) { setInputValue2(e.target.value); }}}
        />
        )
      </div>

    </div>
  );
}

export default ContractBtns;
