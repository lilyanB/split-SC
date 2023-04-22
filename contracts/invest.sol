// SPDX-License-Identifier: lilyan
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract invest is ERC1155, Pausable {
    struct SPLIT {
        uint256 id;
        uint256 supply;
        uint256 price;
        uint256 deployDate;
        uint256 daysToBuy;
        string tokenURI;
    }
    // informations du SPLIT par id
    mapping(uint256 => SPLIT) public SPLITToStruct;
    // nombre total de SPLIT
    uint256 totalSPLIT;
    // list of owner of token
    mapping(uint256 => address[]) private balances;

    address erc20;
    address owner;
    uint256 decimals;

    constructor() ERC1155("") {
        owner = msg.sender;

        createNewToken(
            10,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            0,
            10
        );

        createNewToken(
            1,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            4,
            3
        );

        createNewToken(
            8,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            2,
            3
        );
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function currentSplit() public view returns (uint256) {
        return totalSPLIT;
    }

    function createNewToken(
        uint256 newSupply,
        string memory URIToken,
        uint256 numberDays,
        uint256 priceOfToken
    ) public onlyOwner {
        totalSPLIT += 1;
        for (uint8 i = 0; i < newSupply; i++) {
            balances[totalSPLIT].push(msg.sender);
        }
        SPLIT memory split = SPLIT(
            totalSPLIT,
            newSupply,
            priceOfToken,
            block.timestamp,
            numberDays,
            URIToken
        );
        SPLITToStruct[totalSPLIT] = split;
        _mint(msg.sender, totalSPLIT, newSupply, "0x");
    }

    function uri(uint256 id) public view override returns (string memory) {
        require(
            totalSPLIT >= id,
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = SPLITToStruct[id].tokenURI;
        return
            string(abi.encodePacked(_tokenURI, Strings.toString(id), ".json"));
    }

    function name() external pure returns (string memory) {
        return "My Collection 1.0";
    }

    function supply(uint256 id) public view returns (uint256) {
        return SPLITToStruct[id].supply;
    }

    function percent(
        address account,
        uint256 id
    ) public view returns (uint256) {
        uint256 number = balanceOf(account, id);
        uint256 totalSupply = SPLITToStruct[id].supply;

        return uint256((number * 100) / totalSupply);
    }

    function canBuyAll(address account, uint256 id) public view returns (bool) {
        return (percent(account, id) > 50 && percent(account, id) < 100);
    }

    function setValuesOfNFT(uint256 value, uint256 id) public onlyOwner {
        SPLITToStruct[id].price = value;
    }

    function getValuesOfNFT(uint256 id) public view returns (uint256) {
        return SPLITToStruct[id].price;
    }

    function valueToBuy(
        address account,
        uint256 id
    ) public view returns (uint256) {
        uint256 tokenRest = 100 - percent(account, id);
        return (tokenRest * SPLITToStruct[id].price) / 100;
    }

    function find(address value, uint256 id) public view returns (uint256) {
        uint256 i = 0;
        while (balances[id][i] != value) {
            i++;
        }
        return i;
    }

    function allOwner(uint256 id) public view returns (address[] memory) {
        return balances[id];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
        for (uint256 i = 0; i < amount; i++) {
            uint256 index = find(from, id);
            balances[id][index] = to;
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
        for (uint256 i = 0; i < amounts.length; i++) {
            for (uint256 y = 0; y < amounts[i]; y++) {
                uint256 index = find(from, ids[i]);
                balances[ids[i]][index] = to;
            }
        }
    }

    function burn(address from, uint256 id, uint256 amount) public virtual {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _burn(from, id, amount);
        for (uint256 i = 0; i < amount; i++) {
            uint256 index = find(from, id);
            balances[id][index] = address(0);
        }
    }

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _burnBatch(from, ids, amounts);
        for (uint256 i = 0; i < amounts.length; i++) {
            for (uint256 y = 0; y < amounts[i]; y++) {
                uint256 index = find(from, ids[i]);
                balances[ids[i]][index] = address(0);
            }
        }
    }

    function forceTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        require(
            to == _msgSender() || isApprovedForAll(to, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 index = find(from, id);
            balances[id][index] = to;
        }
        _safeTransferFrom(from, to, id, amount, data);
    }

    function numberOwnersWithoutMe(uint256 id) public view returns (uint256) {
        address[] memory owners = allOwner(id);
        uint256 numberTotal = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] != msg.sender) {
                numberTotal = numberTotal + (1);
            }
        }

        return numberTotal;
    }

    function OwnersWithoutMe(
        uint256 id
    ) public view returns (address[] memory) {
        address[] memory owners = allOwner(id);
        uint256 numberownersWithoutMe = numberOwnersWithoutMe(id);
        address[] memory list = new address[](numberownersWithoutMe);
        uint256 iList = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] != msg.sender) {
                list[iList] = owners[i];
                iList += 1;
            }
        }

        return list;
    }

    function forceBuy(uint256 id) public whenNotPaused {
        require(
            block.timestamp >=
                SPLITToStruct[id].deployDate +
                    SPLITToStruct[id].daysToBuy *
                    1 days,
            "Wait 2 minutes before use this function"
        );
        require(canBuyAll(msg.sender, id), "You can't buy all");

        uint256 numberOfOwnersNotMe = numberOwnersWithoutMe(id);
        address[] memory addressOfOwnersNotMe = OwnersWithoutMe(id);
        uint256 priceOneToken = (SPLITToStruct[id].price /
            SPLITToStruct[id].supply) * (10 ^ decimals);

        IERC20 erc20Contract = IERC20(erc20);

        for (uint256 i = 0; i < numberOfOwnersNotMe; i++) {
            require(
                priceOneToken <=
                    erc20Contract.allowance(msg.sender, address(this))
            );
            require(
                erc20Contract.transferFrom(
                    msg.sender,
                    addressOfOwnersNotMe[i],
                    priceOneToken
                )
            );
            forceTransferFrom(addressOfOwnersNotMe[i], msg.sender, id, 1, "0x");
        }
    }

    function ChangeERC20Address(
        address newErc20,
        uint256 newDeimals
    ) public onlyOwner returns (address) {
        decimals = newDeimals;
        erc20 = newErc20;
        return address(erc20);
    }

    function ERC20Address() public view returns (address) {
        return address(erc20);
    }

    function ERC20Decimals() public view returns (uint256) {
        return decimals;
    }
}
