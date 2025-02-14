// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.sol";
import "hardhat/console.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol"; 
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

contract MemeTokenFactory {
    struct MemeToken {
        string name;
        string symbol;
        string description;
        string imageUrl;
        uint256 fundingRaised;
        address tokenAddress;
        address creator;
        bool isOpen;
    }

    address[] public tokens;
    mapping(address => MemeToken) public tokenInfo;
    
    uint256 public constant CREATION_FEE = 0.0001 ether;
    uint256 public constant FUNDING_GOAL = 24 ether;
    uint256 public constant DECIMALS = 10 ** 18;
    uint256 public constant MAX_SUPPLY = 1_000_000 * DECIMALS;
    uint256 public constant INIT_SUPPLY = 20 * MAX_SUPPLY / 100;
    uint256 public constant INITIAL_PRICE = 3 * 10**13; // 0.00003 ETH
    uint256 public constant K = 8 * 10**15;
    
    address public owner;
    address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    event TokenCreated(address indexed token, string name, address creator);
    event TokenPurchased(address indexed token, uint256 amount, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createToken(
        string memory name,
        string memory symbol,
        string memory imageUrl,
        string memory description
    ) external payable returns (address) {
        require(msg.value >= CREATION_FEE, "Fee not paid");

        Token newToken = new Token(name, symbol, INIT_SUPPLY);
        address tokenAddr = address(newToken);
        
        tokens.push(tokenAddr);
        tokenInfo[tokenAddr] = MemeToken(
            name, symbol, description, imageUrl, 0, tokenAddr, msg.sender, true
        );
        
        emit TokenCreated(tokenAddr, name, msg.sender);
        return tokenAddr;
    }

    function calculateCost(uint256 currentSupply, uint256 tokensToBuy) public pure returns (uint256) {
        uint256 exponent1 = (K * (currentSupply + tokensToBuy)) / 10**18;
        uint256 exponent2 = (K * currentSupply) / 10**18;
        uint256 exp1 = exp(exponent1);
        uint256 exp2 = exp(exponent2);
        uint256 cost = (INITIAL_PRICE * 10**18 * (exp1 - exp2)) / K;
        return cost;
    }

    function exp(uint256 x) internal pure returns (uint256) {
        uint256 sum = 10**18;
        uint256 term = 10**18;
        uint256 xPower = x;
        for (uint256 i = 1; i <= 20; i++) {
            term = (term * xPower) / (i * 10**18);
            sum += term;
            if (term < 1) break;
        }
        return sum;
    }

    function buyToken(address tokenAddr, uint256 amount) external payable {
        MemeToken storage sale = tokenInfo[tokenAddr];
        require(sale.isOpen, "Token sale closed");
        require(sale.fundingRaised < FUNDING_GOAL, "Funding goal met");

        Token token = Token(tokenAddr);
        uint256 currentSupply = token.totalSupply();
        uint256 requiredEth = calculateCost(currentSupply, amount);
        require(msg.value >= requiredEth, "Insufficient ETH sent");

        sale.fundingRaised += msg.value;
        token.mint(amount * DECIMALS, msg.sender);

        if (sale.fundingRaised >= FUNDING_GOAL) {
            _provideLiquidity(tokenAddr, INIT_SUPPLY, sale.fundingRaised);
            sale.isOpen = false;
        }

        emit TokenPurchased(tokenAddr, amount, msg.sender);
    }

    function _provideLiquidity(address tokenAddr, uint256 tokenAmount, uint256 ethAmount) internal {
        Token token = Token(tokenAddr);
        token.approve(UNISWAP_V2_ROUTER, tokenAmount);
        IUniswapV2Router01 router = IUniswapV2Router01(UNISWAP_V2_ROUTER);
        router.addLiquidityETH{value: ethAmount}(
            tokenAddr, tokenAmount, tokenAmount, ethAmount, address(this), block.timestamp
        );
    }

    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
