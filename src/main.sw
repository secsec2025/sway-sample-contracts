contract;

use std::storage::storage_map::*;
use std::storage::storage_string::*;
use std::hash::Hash;
use std::string::String;
use std::primitive_conversions::str::*;
use std::identity::Identity;
use std::address::Address;
use std::logging::log;
//use ownership::*;
//use src_5::*;

// struct VoteOption {
//     optionName: str[20],
// }


abi VotingContract {

    #[storage(read, write)]
	fn set_voting_enabled(flag: bool) -> bool;

    #[storage(read)]
	fn get_voting_enabled() -> bool;

    #[storage(read, write)]
	fn add_vote_option(optionName: str[3]) -> u64;

    #[storage(read)]
	fn get_vote_options() -> Vec<str[3]>;
    

    #[storage(read, write)]
    fn set_vote_name(voteName: String);

    #[storage(read)]
    fn get_vote_name() -> String;

    #[storage(read, write)]
    fn set_vote_image(voteName: String);

    #[storage(read)]
    fn get_vote_image() -> String;

    #[storage(read, write)]
    fn vote(voteOption: u64) -> u64;

    #[storage(read)]
    fn has_voted() -> bool;

    #[storage(read)]
    fn get_votes() -> Vec<u64>;
}

storage {
    //owner: Ownership = Ownership::initialized(Identity::Address(Address::from(0x5facbc0514ffccc4b9743a9150804fa5b62af2ac5e2045c94d6429a4a405d932))),

    isEnabled: bool = false,
    voteName: StorageString = StorageString{},
    voteImage: StorageString = StorageString{},
    voteOptions: StorageMap<u64, str[3]> = StorageMap{},
    optionCount: u64 = 0,
    votes: StorageMap<u64, u64> = StorageMap{},
    votedPeople: StorageMap<Address, bool> = StorageMap{},
}

impl VotingContract for Contract {

    #[storage(read, write)]
	fn set_voting_enabled(flag: bool) -> bool {
        //storage.owner.only_owner();
        storage.isEnabled.write(flag);
        return flag;
    }

    #[storage(read)]
	fn get_voting_enabled() -> bool {
        return storage.isEnabled.read();
    }


    #[storage(read, write)]
	fn add_vote_option(optionName: str[3]) -> u64 {
        //storage.owner.only_owner();

        let index = storage.optionCount.read();
        let op: str[3] = from_str_array(optionName).try_as_str_array().unwrap();
        storage.voteOptions.insert(index, op);
        storage.votes.insert(index, 0);
        storage.optionCount.write(index + 1);
        return index;
	}


    #[storage(read)]
	fn get_vote_options() -> Vec<str[3]> {
        let mut  v: Vec<str[3]> = Vec::new();

        let mut i = 0;
        while i < storage.optionCount.read() {
            let op: str[3] = storage.voteOptions.get(i).try_read().unwrap();
            v.push(op);
            i += 1;
        }
        return v;
	}
    
    

    #[storage(read, write)]
    fn set_vote_name(voteName: String) {
        //storage.owner.only_owner();
        storage.voteName.write_slice(voteName);
    }

    #[storage(read)]
    fn get_vote_name() -> String {
        let name = storage.voteName.read_slice();
        return match name {
            Some(name) => {name},
            None => {String::from_ascii_str("")}
        }
    }

    #[storage(read, write)]
    fn set_vote_image(voteImage: String) {
        //storage.owner.only_owner();
        storage.voteImage.write_slice(voteImage);
    }

    #[storage(read)]
    fn get_vote_image() -> String {
        let image = storage.voteImage.read_slice();
        return match image {
            Some(image) => {image},
            None => {String::from_ascii_str("")}
        }
    }


    #[storage(read, write)]
    fn vote(voteOption: u64) -> u64 {
        // Check if voting is enabled
        assert(storage.isEnabled.read());

        // Get caller address
        let voter: Identity = msg_sender().unwrap();
        assert(voter.is_address());

        // Check if this address has already voted
        assert(storage.votedPeople.get(voter.as_address().unwrap()).try_read().is_none());
        
        // Perform vote
        let mut currentVoteCount: u64 = storage.votes.get(voteOption).try_read().unwrap();
        currentVoteCount = currentVoteCount + 1;
        storage.votes.insert(voteOption, currentVoteCount);

        // Mark this address as voted
        storage.votedPeople.insert(voter.as_address().unwrap(), true);

        return currentVoteCount;
    }

    #[storage(read)]
    fn has_voted() -> bool {
        let voter: Identity = msg_sender().unwrap();
        assert(voter.is_address());

        let mut isVoted: bool = false;
        if (storage.votedPeople.get(voter.as_address().unwrap()).try_read().is_none()) {
            isVoted = false;
        } else {
            isVoted = true;
        }
        return isVoted;
    }

    #[storage(read)]
    fn get_votes() -> Vec<u64> {
        let mut  v: Vec<u64> = Vec::new();

        let mut i = 0;
        while i < storage.optionCount.read() {
            let voteCount: u64 = storage.votes.get(i).try_read().unwrap();
            v.push(voteCount);
            i += 1;
        }
        return v;
    }
}