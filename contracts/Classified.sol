// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Classified {
    event TradeStatusChange(uint256 ad, bytes32 status);

    IERC20 currencyToken;
    IERC721 itemToken;
    
    struct Trade {
        address poster;
        uint256 item;
        uint256 price;
        bytes32 status; // Open, Executed, Cancelled
    }

    mapping(uint256 => Trade) public trades;

    uint256 tradeCounter;

    constructor(address _currencyTokenAddress, address _itemTokenAddress) {
        currencyToken = IERC20(_itemTokenAddress);
        itemToken = IERC721(_currencyTokenAddress);
        tradeCounter = 0;
    }

    function getTrade(uint256 _trade) public virtual view returns(address, uint256, uint256, bytes32) {
        Trade memory trade = trades[ _trade ];
        return ( trade.poster, trade.item, trade.price, trade.status );
    }

    function openTrade(uint256 _item, uint256 _price) public virtual {
        itemToken.transferFrom(msg.sender, address(this), _item);
        trades[tradeCounter] = Trade({ poster: msg.sender, item: _item, price: _price, status: "Open" });
        tradeCounter += 1;
        emit TradeStatusChange(tradeCounter - 1, "Open"); 
    }

    function executeTrade(uint256 _trade) public virtual {
        Trade memory trade = trades[ _trade ];
        require(trade.status == "Open", "Trade is not Open.");
        currencyToken.transferFrom(msg.sender, trade.poster, trade.price);
        itemToken.transferFrom(address(this), msg.sender, trade.item);
        trade.status = "Executed";
        emit TradeStatusChange(_trade, "Executed");
    }

    function cancelTrade(uint256 _trade) public virtual {
        Trade memory trade = trades[ _trade ];
        require(trade.poster == msg.sender, "Trade can be cancelled only by poster.");
        require(trade.status == "Open", "This trade is not Open.");
        itemToken.transferFrom(address(this), trade.poster, trade.item);
        trade.status = "Cancelled";
        emit TradeStatusChange(_trade, "Cancelled");
    }
}
