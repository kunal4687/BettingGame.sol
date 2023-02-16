// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

contract SimpleGame {
    address payable public owner;
    uint public minBet;
   address payable[] public players;

     uint public prizePool;
    bool public gameFinished;
    uint8 public winningNumber;
    mapping(address => uint) public playerBets;
    mapping(address => bool) public winners;

    constructor() {
        owner = payable(msg.sender);
        minBet = 1 ether;
        gameFinished = true;
    }



// clear the mapping by resetting each key-value pair
function clearWinners() public {
    for (uint i = 0; i < players.length; i++) {
        delete winners[players[i]];
    }
}

    function bet(uint number) payable public {
        require(msg.value >= minBet, "Minimum bet not met");
        require(gameFinished == true, "Game in progress");

        playerBets[msg.sender] = number;
        prizePool += msg.value;

        if (number == winningNumber) {
            winners[msg.sender] = true;
        }

        if (address(this).balance > prizePool) {
            gameFinished = false;
        }
    }

    function endGame() public {
        require(msg.sender == owner, "Only the owner can end the game");
        require(gameFinished == false, "Game already finished");

        uint totalWinners = 0;
        for (uint i = 0; i < players.length; i++) {
            if (winners[players[i]]) {
                totalWinners += 1;
            }
        }
        uint winningsPerPlayer = prizePool / totalWinners;

        for (uint i = 0; i < players.length; i++) {
            address payable player = payable(players[i]);
            if (winners[player]) {
                player.transfer(winningsPerPlayer);
            }
        }

        reset();
    }

    function reset() private {
        prizePool = 0;
        winningNumber = uint8(block.timestamp % 10 + 1);
        gameFinished = true;
        delete players;
        
    }
}
