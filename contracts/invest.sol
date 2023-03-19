// SPDX-License-Identifier: lilyan
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract invest is ERC1155, Pausable {
    uint256 tokenIDCounter = 1;
    uint256 public constant WineSupply = 10;
    uint256 public constant WatchSupply = 1;
    uint256 public constant NikeSupply = 8;
    uint256 public constant WineValueUSDT = 10;
    uint256 public constant WatchCurrentValueUSDT = 3;
    uint256 public constant NikeCurrentValueUSDT = 3;

    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public NFTPrice;
    mapping(uint256 => uint256) public _deployDate;
    mapping(uint256 => uint256) public _forceForDays;
    // Mapping from token ID to account balances
    mapping(uint256 => address[]) private balances;

    address erc20;
    address owner;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC1155("") {
        owner = msg.sender;

        createNewToken(
            WineSupply,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            0,
            WineValueUSDT
        );

        createNewToken(
            WatchSupply,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            0,
            WatchCurrentValueUSDT
        );

        createNewToken(
            NikeSupply,
            "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/",
            0,
            NikeCurrentValueUSDT
        );
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function currentID() public view returns (uint256) {
        return tokenIDCounter;
    }

    function createNewToken(
        uint256 newSupply,
        string memory URIToken,
        uint256 numberDays,
        uint256 priveOfToken
    ) public onlyOwner {
        tokenSupply[tokenIDCounter] = newSupply;
        _mint(msg.sender, tokenIDCounter, newSupply, "");
        NFTPrice[tokenIDCounter] = priveOfToken;
        _setTokenURI(tokenIDCounter, URIToken);
        _setDeployDate(tokenIDCounter);
        _setForceForDays(tokenIDCounter, numberDays);

        for (uint8 i = 0; i < WineSupply; i++) {
            balances[tokenIDCounter].push(msg.sender);
        }

        tokenIDCounter += 1;
    }

    function _setForceForDays(
        uint256 tokenId,
        uint256 numberDays
    ) public onlyOwner {
        _forceForDays[tokenId] = numberDays;
    }

    function _setDeployDate(uint256 tokenId) public onlyOwner {
        _deployDate[tokenId] = block.timestamp;
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) public onlyOwner {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function uri(
        uint256 _tokenid
    ) public view override returns (string memory) {
        require(
            tokenSupply[_tokenid] > 0,
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[_tokenid];
        return
            string(
                abi.encodePacked(_tokenURI, Strings.toString(_tokenid), ".json")
            );
    }

    function name() external pure returns (string memory) {
        return "My Collection 1.0";
    }

    function supply(uint256 id) public view returns (uint256) {
        return tokenSupply[id];
    }

    function percent(
        address account,
        uint256 id
    ) public view returns (uint256) {
        uint256 number = balanceOf(account, id);
        uint256 totalSupply = tokenSupply[id];

        return uint256((number * 100) / totalSupply);
    }

    function canBuyAll(address account, uint256 id) public view returns (bool) {
        return (percent(account, id) > 50 && percent(account, id) < 100);
    }

    function setValuesOfNFT(uint256 value, uint256 id) public onlyOwner {
        NFTPrice[id] = value;
    }

    function getValuesOfNFT(uint256 id) public view returns (uint256) {
        return NFTPrice[id];
    }

    function valueToBuy(
        address account,
        uint256 tokenId
    ) public view returns (uint256) {
        return NFTPrice[tokenId] / (100 - percent(account, tokenId));
    }

    function find(address value, uint256 id) public view returns (uint256) {
        uint256 i = 0;
        while (balances[id][i] != value) {
            i++;
        }
        return i;
    }

    function allOwner(uint256 tokenId) public view returns (address[] memory) {
        return balances[tokenId];
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
        for (uint256 i = 0; i < amount; i++) {
            uint256 index = find(from, id);
            balances[id][index] = to;
        }
        _safeTransferFrom(from, to, id, amount, data);
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

    function numberOwnersWithoutMe(
        uint256 tokenId
    ) public view returns (uint256) {
        address[] memory owners = allOwner(tokenId);
        uint256 numberTotal = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] != msg.sender) {
                numberTotal = numberTotal + (1);
            }
        }

        return numberTotal;
    }

    function OwnersWithoutMe(
        uint256 tokenId
    ) public view returns (address[] memory) {
        address[] memory owners = allOwner(tokenId);
        uint256 numberownersWithoutMe = numberOwnersWithoutMe(tokenId);
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

    function forceBuy(uint256 tokenId) public whenNotPaused {
        require(
            block.timestamp >=
                _deployDate[tokenId] + _forceForDays[tokenId] * 1 days,
            "Wait 2 minutes before use this function"
        );
        require(canBuyAll(msg.sender, tokenId), "You can't buy all");

        uint256 numberOfOwnersNotMe = numberOwnersWithoutMe(tokenId);
        address[] memory addressOfOwnersNotMe = OwnersWithoutMe(tokenId);
        uint256 priceOneToken = NFTPrice[tokenId] / tokenSupply[tokenId];

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
            forceTransferFrom(
                addressOfOwnersNotMe[i],
                msg.sender,
                tokenId,
                1,
                "0x"
            );
        }
    }

    function ChangeERC20Address(
        address newErc20
    ) public onlyOwner returns (address) {
        erc20 = newErc20;
        return address(erc20);
    }

    function ERC20Address() public view returns (address) {
        return address(erc20);
    }
}
