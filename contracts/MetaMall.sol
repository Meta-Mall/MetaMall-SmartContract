// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC4907.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract MetaMall is ERC4907 {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    address contractOwner;

    struct Store {
        address owner;
        uint256 tokenId;
        uint16 storeNumber;
        uint256 price; ///price per month
        uint256 rent;
        bool isSaleable;
        bool isRentable;
    }

    struct StoreDetails {
        address owner;
        uint256 tokenId;
        uint16 storeNumber;
        uint256 price; //wei currency
        uint256 rent;
        bool isSaleable; //sale rent owned
        bool isRentable;
        address user;
        uint256 expires;
    }

    Store[][] stores;

    function mint() internal returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(contractOwner, newItemId);
        return newItemId;
    }

    constructor() ERC4907("MetaMall Shops", "LL") {
        contractOwner = msg.sender;

        //Floors
        stores.push();
        stores.push();
        stores.push();
        stores.push();
        stores.push();

        //Floor 0
        for (uint16 i = 0; i < 32; i++) {
            stores[0].push(Store(address(this), mint(), i, 100000000000000000, 0, true, false));
        }

        //Floor 1
        for (uint16 i = 0; i < 32; i++) {
            stores[1].push(Store(address(this), mint(), i + uint16(stores[0].length), 100000000000000000, 0, true, false));
        }

        setApprovalForAll(address(this), true);
    }

    //--------------- F L O O R   M A N A G E M E N T ----------------

    function removeFloor() public {
        require(msg.sender == contractOwner, "Not Authorised");
        require(stores[stores.length - 1].length == 0, "Floor must be empty to be deleted");
        stores.pop();
    }

    function addFloor() public {
        require(msg.sender == contractOwner, "Not Authorised");
        stores.push();
    }

    function addFloorAtIndex(uint index) public {
        //GAS EXPENSIVE
        require(msg.sender == contractOwner, "Not Authorised");

        stores.push();
        for (uint i = stores.length - 1; i > index; i--) { stores[i] = stores[i - 1]; }
        delete stores[index];
    }

    function removeFloorAtIndex(uint index) public {
        require(msg.sender == contractOwner, "Not Authorised");
        require(stores[index].length == 0, "Floor must be empty to be deleted");

        for (uint i = index; i < stores[index].length - 1; i++) { stores[index][i] = stores[index][i + 1]; }
        stores[index].pop();
    }

    // ------------- G E T T E R   V I E W   F U N C T I O N S -----------------

    function getStore(uint floor, uint index) public view returns (StoreDetails memory) {
        require(floor < stores.length && index < stores[floor].length, "Invalid Store");
        return getStoreDetails(stores[floor][index]);
    }

    function getStoreDetails(Store memory store) public view returns (StoreDetails memory) {
        StoreDetails memory s = StoreDetails({
            owner: store.owner,
            tokenId: store.tokenId,
            storeNumber: store.storeNumber,
            price: store.price,
            rent: store.rent,
            isSaleable: store.isSaleable,
            isRentable: store.isRentable,
            user: _users[store.tokenId].user,
            expires: _users[store.tokenId].expires
        });
        return s;
    }

    function getAllStores() public view returns (Store[][] memory) { return stores; }

    function getOwnedStores(address owner) public view returns (StoreDetails[] memory) {
        uint count = 0;
        uint index = 0;

        StoreDetails[] memory owned;
        for (uint i = 0; i < stores.length; i++) {
            for (uint j = 0; j < stores[i].length; j++) {
                if (stores[i][j].owner == owner) { count++; }
            }
        }

        owned = new StoreDetails[](count);
        for (uint i = 0; i < stores.length; i++) {
            for (uint j = 0; j < stores[i].length; j++) {
                if (stores[i][j].owner == owner) {
                    owned[index++] = getStoreDetails(stores[i][j]);
                }
            }
        }
        return owned;
    }

    // function getRentedStores() public view returns (StoreDetails[] memory) {
    //     uint count = 0;
    //     uint index = 0;
    //
    //     StoreDetails[] memory rented;
    //     for (uint i = 0; i < stores.length; i++) {
    //         for (uint j = 0; j < stores[i].length; j++) {
    //             if (userOf(stores[i][j].tokenId) != address(0)) { count++; }
    //         }
    //     }
    //
    //     rented = new StoreDetails[](count);
    //     for (uint i = 0; i < stores.length; i++) {
    //         for (uint j = 0; j < stores[i].length; j++) {
    //             if (userOf(stores[i][j].tokenId) != address(0)) {
    //                 rented[index++] = getStoreDetails(stores[i][j]);
    //             }
    //         }
    //     }
    //     return rented;
    // }

    // function getAvailableStores() public view returns (StoreDetails[] memory) {
    //     uint count = 0;
    //     uint index = 0;

    //     StoreDetails[] memory available;
    //     for (uint i = 0; i < stores.length; i++) {
    //         for (uint j = 0; j < stores[i].length; j++) {
    //             if (stores[i][j].isSaleable || stores[i][j].isRentable) { count++; }
    //         }
    //     }

    //     available = new StoreDetails[](count);
    //     for (uint i = 0; i < stores.length; i++) {
    //         for (uint j = 0; j < stores[i].length; j++) {
    //             if (stores[i][j].isSaleable || stores[i][j].isRentable) {
    //                 available[index++] = getStoreDetails(stores[i][j]);
    //             }
    //         }
    //     }
    //     return available;
    // }

    // ----------------- S H O P   N F T   M A N A G E M E N T -----------------

    function setRentFee(uint floor, uint storeNumber, uint256 _amountPerMonth) public {
        require(_isApprovedOrOwner(_msgSender(), stores[floor][storeNumber].tokenId), "Caller is not token owner nor approved");
        require(_amountPerMonth > 0, "Invalid Price");
        stores[floor][storeNumber].rent = _amountPerMonth;
    }

    function setPrice(uint floor, uint storeNumber, uint256 _price) public {
        require(_isApprovedOrOwner(_msgSender(), stores[floor][storeNumber].tokenId), "Caller is not token owner nor approved");
        require(_price > 0, "Invalid Price");
        stores[floor][storeNumber].price = _price;
    }

    function setRentable(uint floor, uint storeNumber, bool _rentable) public {
        require(_isApprovedOrOwner(_msgSender(), stores[floor][storeNumber].tokenId), "Caller is not token owner nor approved");
        require(floor < stores.length, "Invalid Floor");
        require(storeNumber < stores[floor][stores[floor].length].storeNumber , "Invalid Store");

        uint256 tokenId = stores[floor][storeNumber].tokenId;
        require(userOf(tokenId) == address(0), "Store already rented");
        stores[floor][storeNumber].isRentable = _rentable;
    }

    function setSaleable(uint floor, uint storeNumber, bool _saleable) public {
        require(_isApprovedOrOwner(_msgSender(), stores[floor][storeNumber].tokenId), "Caller is not token owner nor approved");
        require(floor < stores.length, "Invalid Floor");
        require(storeNumber < stores[floor][stores[floor].length].storeNumber , "Invalid Store");

        uint256 tokenId = stores[floor][storeNumber].tokenId;
        require(userOf(tokenId) == address(0), "Store is rented out. Wait for rent tenure to be over before selling.");
        stores[floor][storeNumber].isSaleable = _saleable;
    }

    function rent(uint floor, uint storeNumber, uint256 _tokenId, uint64 month) public payable virtual {
       require(floor < stores.length, "Invalid Floor");
        require(storeNumber < stores[floor][stores[floor].length].storeNumber , "Invalid Store");

        uint256 dueAmount = stores[floor][storeNumber].rent * month;
        require(msg.value == dueAmount, "Incorrect amount");
        require(userOf(_tokenId) == address(0), "Already rented");
        require(stores[floor][storeNumber].isRentable, "Renting disabled for the NFT");

        payable(ownerOf(_tokenId)).transfer(dueAmount);
        UserInfo storage info = _users[_tokenId];
        info.user = msg.sender;
        uint64 timeInSeconds = month * 2629746;
        info.expires = uint256(block.timestamp) + timeInSeconds; //convert months to seconds

        emit UpdateUser(_tokenId, msg.sender, timeInSeconds);
        stores[floor][storeNumber].isRentable = false;
        stores[floor][storeNumber].isSaleable = false;
    }

    function buy(uint floor, uint storeNumber, uint256 _tokenId) public payable {
        require(floor < stores.length, "Invalid Floor");
        require(storeNumber < stores[floor][stores[floor].length].storeNumber , "Invalid Store");
        require(stores[floor][storeNumber].isSaleable == true, "This land is not availble for sale.");
        require(msg.value >= stores[floor][storeNumber].price, "Incorrect amount");

        payable(ownerOf(_tokenId)).transfer(msg.value);
        safeTransferFrom(ownerOf(_tokenId), msg.sender, _tokenId);

        stores[floor][storeNumber].owner = msg.sender;
        stores[floor][storeNumber].isSaleable = false;
        stores[floor][storeNumber].isRentable = false;
    }
}
