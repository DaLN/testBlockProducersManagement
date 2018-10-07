pragma solidity ^0.4.0;

contract ERC20Coin{
  function totalSupply() constant public returns (uint256 supply);
  function balanceOf(address _owner) constant public  returns (uint256 balance);
}

contract BlockProducersManagement {

  address public owner;

  // Constructor - set the owner of the contract
  constructor() public {
    owner = msg.sender;
  }

  struct Vote {
    address voter;
    address choice;
    uint256 weight;
    bool initialised;
  }

  //Block Producers candidates that can be elected for a specific chain.
  mapping(address => mapping(address => bool)) candidates;

  //vote for Block Producers candidates for a specific chain.
  //      chain              voter      choice
  mapping(address => mapping(address => Vote)) votes;

  //Coin contract address for a specific chain.
  mapping(address => address) coinContracts;

  //Delegation.
  //      chain              delegatedto / weight
  mapping(address => mapping(address => uint256)) delegation;

  //vote for Block Producers candidates for a specific chain.
  //      chain              voter       choice
  mapping(address => mapping(address => bool)) voted;

  address[] public candidateAddresses;
  address[] public votersVotedAddresses;

  modifier onlyOwner(){
    if (msg.sender == owner) {
      _;
    }
  }

  modifier notAlreadyRegistered(address chain) {
    require(
      candidates[chain][msg.sender] == true,
      "Candidate is already registered."
      );
      _;
    }

    modifier alreadyRegistered(address chain) {
      require(
        candidates[chain][msg.sender] == false,
        "Candidate is not registered."
        );
        _;
      }

      modifier candidateExists(address chain, address candidateID) {
        require(
          candidates[chain][candidateID] == true,
          "Candidate is not registered."
          );
          _;
        }

        modifier hasNotVoted(address chain, address voterOrDelegator) {
          require(
            voted[chain][voterOrDelegator] == false,
            "You have already voted."
            );
            _;
          }

          function resetValues(address chain) internal onlyOwner  {
            for (uint256 i = 0; i < votersVotedAddresses.length; i++) {
              voted[chain][votersVotedAddresses[i]] = false;
              votes[chain][votersVotedAddresses[i]].initialised = false;
              delegation[chain][votersVotedAddresses[i]] = 0;
            }
            delete votersVotedAddresses;
          }

          /// Register yourself as a candidate to be a Block Producer on a specific chain.
          function registerCandidate(address chain) public notAlreadyRegistered(chain) {
            candidates[chain][msg.sender] = true;
            candidateAddresses.push(msg.sender);
          }

          /// Unregister yourself as a candidate to be a Block Producer on a specific chain.
          function unregisterCandidate(address chain) public alreadyRegistered(chain) {
            candidates[chain][msg.sender] = false;
          }

          /// Vote for a candidate to be a Block Producer on a specific chain.
          function voteFor(address chain, address choice) public
            candidateExists(chain, choice) hasNotVoted(chain, msg.sender) {
              ERC20Coin coinContract = ERC20Coin(coinContracts[chain]);
              uint256 weight = coinContract.balanceOf(msg.sender);
              weight += delegation[chain][msg.sender];
              votes[chain][msg.sender] = Vote(msg.sender, choice, weight, true);
              votersVotedAddresses.push(msg.sender);
              voted[chain][msg.sender] = true;
          }

          /// Delegate your vote to the voter $(to).
          function delegate(address chain, address to) public hasNotVoted(chain, msg.sender) {
            ERC20Coin coinContract = ERC20Coin(coinContracts[chain]);
            uint256 weight = coinContract.balanceOf(msg.sender);
            weight += delegation[chain][msg.sender];
            if(voted[chain][to] == true && votes[chain][msg.sender].initialised) {
              votes[chain][msg.sender].weight += weight;
              } else {
                delegation[chain][to] += weight;
              }
              voted[chain][msg.sender] = true;
            }
            mapping(address => uint256) public voteResults;

            function endElection(address chain) public {
              for(uint256 i = 0; i < votersVotedAddresses.length; i++) {
                if (votes[chain][votersVotedAddresses[i]].initialised) {
                  voteResults[votes[chain][votersVotedAddresses[i]].choice] +=
                  votes[chain][votersVotedAddresses[i]].weight;
                }
              }
              resetValues(chain);
              //Sorting will be done off chain.
            }
          }
