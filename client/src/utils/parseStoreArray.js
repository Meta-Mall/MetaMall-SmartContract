import { parseStore } from ".";

const parseStoreArray = arr => {
    return arr.map(store => parseStore(store));
}

export { parseStoreArray };