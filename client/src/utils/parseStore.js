const parseStore = store => {
    return {
        price: store[0],
        rent: store[1],
        area: store[2],
        storeNumber: store[3],
        owner: store[4],
        tokenId: store[5],
        currentUser: store[6],
        status: store[7],
    }
}

export { parseStore };