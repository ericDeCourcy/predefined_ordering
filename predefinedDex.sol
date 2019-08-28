pragma solidity ^0.5.0; 

import "SafeMath.sol";  //What a great library, wow

/**
 * @title Simplified DEX implementing predefined ordering scheme for matching and filling orders
 * @author Eric DeCourcy
 * @dev Implementation of the predifined ordering scheme to mitigate front running in a generalized dex
 *
 * This implementation assumes various simplifications about the DEX
 * 
 * one assumption is that, for now, this code will represent balances of tokens as a mapping of uint to 
 * address rather than using calls to ERC20's, although this could be implemented easily.
 * 
 * another assumption is that the dex relies on a maker-taker scheme. There are no options for partially
 * filling an order, or for market-buying (at least not within the code. Market buying could be implemented
 * by simply taking the best order).
 */
contract predefinedDex {
    using SafeMath for uint256;
    
    /// @notice admin that controls revealing the ordering
    /// unfortunately, there's still some centralizaiton. Sorry crypto-kids
    address admin;
    
    /// @notice number of blocks user has to commit encrypted orders
    uint256 commitBlocks;
    
    /// @notice number of blocks user has to reveal contents of encrypted orders
    /// @dev may be removed in future in favor of a scheme in which reveal and process happens in the same stage
    uint256 revealBlocks;
    
    /// @notice number of blocks the admin has to reveal the ordering parameter
    uint256 orderRevealBlocks;
    
    /// @notice number of blocks for users to have thier orders processed
    /// @notice in this time span, admin should commit a new random seed (for next round)
    /// @dev most likely requires more gas than committing or revealing a transaction, so
    /// should always be larger than commitBlock and revealBlocks
    uint256 processBlocks;
    
    /// @notice the number given by admin to seed the ordering for this round. Should be the hash of the actual
    /// ordering seed
    uint256 orderSeed;
    
    /// @notice the actual ordering seed, which is revealed by admin after the "user reveal" stage
    /// @dev keccak256(orderReveal) should always == orderSeed
    uint256 orderReveal;
    
    /// @notice keeps track of balances per token per user
    /// "token" is determined by constant uint256 value enumerated below
    mapping (uint256 => mapping (address => uint256)) balances;
    
    /// @notice enums 5 different token tickers
    enum tokens { AAA, BBB, CCC, DDD, EEE }
    
    /// @notice enums the 4 different stages
    enum stages { COMMIT_STAGE, REVEAL_STAGE, ORDER_STAGE, PROCESS_STAGE } 
    
    /// @notice cycles through the enumerated stages as program runs
    uint256 currentStage;
    
    
//TODO: define modifier onlyAdmin
//TODO: define modifier onlyCommitStage
//TODO: define modifier onlyRevealStage
//TODO: define modifier onlyOrderRevealStage
//TODO: define modifier onlyProcessStage



    
    /// @notice sets all timing parameters for the process and designates contract creator as the admin
    function constructor(uint256 _commitBlocks, uint256 _revealBlocks, uint256 _orderRevealBlocks, uint256 _processBlocks) returns (bool)
    {
        commitBlocks = _commitBlocks;
        revealBlocks = _revealBlocks;
        orderRevealBlocks = _orderRevealBlocks;
        processBlocks = _processBlocks;
        admin = msg.sender;
        
        currentStage = PROCESS_STAGE;
        
        return true;
    }
    
    /// @notice Admin sets the orderSeed in this function
    /// @notice Admin should make extra, super-duper sure to ensure they have recorded "original" such that
    /// keccak(original) == _seed
    function seedOrdering(uint256 _seed) onlyAdmin onlyProcessStage returns (bool) 
    {
        orderSeed = _seed;
        return true;
    }
    
    /// @notice Admin reveals the ordering Value
    function revealOrdering(uint256 _revealValue) onlyAdmin onlyOrderRevealStage returns (bool)
    {
        require(keccak256(_revelValue) == orderSeed, "Incorrect _revealValue!");
        orderReveal = _revealValue;
        return true;
    }
    
    
        
