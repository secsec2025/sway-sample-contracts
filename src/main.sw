contract;

use std::storage::storage_vec::*;
use std::storage::storage_map::*;
use std::storage::storage_string::*;
use std::hash::Hash;
use std::string::String;
use std::primitive_conversions::str::*;

// struct VoteOption {
//     optionName: str[20],
// }


abi VotingContract {

    #[storage(read, write)]
	fn add_vote_option(optionName: str[3]) -> u64;

    #[storage(read)]
	fn get_vote_options() -> Vec<str[3]>;
    

    #[storage(read, write)]
    fn set_vote_name(voteName: String);

    #[storage(read)]
    fn get_vote_name() -> String;

    #[storage(read, write)]
    fn vote() -> u64;

    #[storage(read)]
    fn get_votes() -> u64;
}

storage {
    voteName: StorageString = StorageString{},
    voteOptions: StorageMap<u64, str[3]> = StorageMap{},
    optionCount: u64 = 0,
    votes: u64 = 0
}

impl VotingContract for Contract {

    
    #[storage(read, write)]
	fn add_vote_option(optionName: str[3]) -> u64 {
        let index = storage.optionCount.read();
        let op: str[3] = from_str_array(optionName).try_as_str_array().unwrap();
        storage.voteOptions.insert(index, op);
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
    fn vote() -> u64 {
        let incremented = storage.votes.read() + 1;
        storage.votes.write(incremented);
        incremented
    }

    #[storage(read)]
    fn get_votes() -> u64 {
        storage.votes.read()
    }
}