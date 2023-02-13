pragma solidity ^0.8.0;

contract MetaMall {
    
    //Admin of Contract
    address contractOwner;

    struct UserInfo {
        address user;
        uint256 expires;
    }

    struct Store {
        uint256 price;
        uint256 rent;
        uint256 area;
        uint16 storeNumber;
        address owner;
        uint256 tokenId;
        UserInfo currentUser;
        uint8 status;
    }

    //give option to owner tos et rent of his land

    Store[][] stores;

    constructor() {

        contractOwner = msg.sender;
        
        //Floors
        stores.push();
        stores.push();
        stores.push();
        stores.push();
        stores.push();

        //Floor 0
        stores[0].push(Store(10, 0, 100, 1, address(0), 1, UserInfo(address(0), 0), 1));
        stores[0].push(Store(10, 0, 100, 2, address(0), 1, UserInfo(address(0), 0), 1));
        stores[0].push(Store(10, 0, 100, 3, address(0), 1, UserInfo(address(0), 0), 1));
        stores[0].push(Store(15, 0, 500, 4, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(15, 0, 500, 5, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(20, 0, 700, 6, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(20, 0, 700, 7, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(25, 0, 800, 8, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(25, 0, 800, 9, address(0), 5, UserInfo(address(0), 0), 5));
        stores[0].push(Store(30, 0, 1000, 10, address(0), 5, UserInfo(address(0), 0), 5));

        //Floor 1
        stores[1].push(Store(5, 0, 100, 11, address(0), 1, UserInfo(address(0), 0), 1));
        stores[1].push(Store(5, 0, 100, 12, address(0), 1, UserInfo(address(0), 0), 1));
        stores[1].push(Store(5, 0, 100, 13, address(0), 1, UserInfo(address(0), 0), 1));
        stores[1].push(Store(8, 0, 500, 14, address(0), 5, UserInfo(address(0), 0), 5));
        stores[1].push(Store(8, 0, 500, 15, address(0), 5, UserInfo(address(0), 0), 5));
    }

    function removeFloor() public {
        require(msg.sender == contractOwner);
        require(stores[stores.length - 1].length == 0);

        stores.pop();
    }

    function addFloor() public {
        require(msg.sender == contractOwner);
        stores.push();
    }

    function addFloorAtIndex(uint index) public {
        //GAS EXPENSIVE
        require(msg.sender == contractOwner);

        stores.push();
        for(uint i = stores.length - 1; i > index; i--){
            stores[i] = stores[i-1];    
        }

        delete stores[index];
    }

    function removeFloorAtIndex(uint index) public {
        require(stores[index].length == 0);

        for(uint i = index; i < stores[index].length - 1; i++){
        stores[index][i] = stores[index][i+1];      
        }
        stores[index].pop();
    }

    function getAllStores() public view returns (Store[][] memory) {
        return stores;
    }

    function getStore(uint floor, uint index) public view returns (Store memory) {
        require(floor < stores.length && index < stores[floor].length);
        return stores[floor][index];
    }
}
