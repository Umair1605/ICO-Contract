// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ICO_Contract {
    using SafeMath for uint256;

    ERC20 public token;

    address public wallet; // Address where funds are collected
    uint256 public rate; // How many token units a buyer gets per wei
    uint256 public weiRaised; 
    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public cap;

    mapping(address => uint256) public contributions;
    /**
     *  check its open or not
    */
    modifier whileOpen() {
        require(block.timestamp >= openingTime, "It's Not Open Yet");
        require(block.timestamp <= closingTime, "It's Closed Now");
        _;
    }

    /**
    * Event for token purchase logging
    */
    event TokenPurchase (
        address indexed purchaser,
        address indexed investor,
        uint256 value,
        uint256 amount,
        uint256 weiRaised
    );

    /**
    * Constructor
    */
    constructor (
        uint256 _rate, 
        address _wallet, 
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime
    ) {
        require(_rate > 0,"Rate is less than zero");
        require(_wallet != address(0),"Wallet Has Zero Address");
        require(_openingTime >= block.timestamp,"Open Time is less than current time");
        require(_closingTime >= _openingTime,"Closing Time is less than Open time");

        cap = 100000000 * (10 ** 18);
        openingTime = _openingTime;
        closingTime = _closingTime;
        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    receive() external payable {}

    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }

    /**
    * _investor give funds and get token 
    */
    
    function buyTokens(
        address _investor
    ) public payable whileOpen  {

        uint256 weiAmount = msg.value;
        
        require(_investor != address(0),"Beneficiary has zero address");
        require(weiAmount != 0, "Amount is Zero");
        require(weiRaised.add(weiAmount) <= cap , "Wei Raised Has exceed");
        
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.transfer(_investor, tokens);
        
        emit TokenPurchase(
            msg.sender,
            _investor,
            weiAmount,
            tokens,
            weiRaised
        );

        _updatePurchasingState(_investor, weiAmount);

        _transferFunds();
    }

    /**
    * update the contribution
    */
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    ) internal {
        contributions[_beneficiary] = _weiAmount;
    }

    /**
    * return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount (
        uint256 _weiAmount
    ) internal view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    /**
    * Transfer fund to wallet
    */
    function _transferFunds() internal {
        payable(wallet).transfer(msg.value);
    }
}