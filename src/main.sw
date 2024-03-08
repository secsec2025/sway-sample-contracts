contract;

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
    fn set_vote_image(voteName: String);

    #[storage(read)]
    fn get_vote_image() -> String;

    #[storage(read, write)]
    fn vote(voteOption: u64) -> u64;

    #[storage(read)]
    fn get_votes() -> Vec<u64>;
}

storage {
    voteName: StorageString = StorageString{},
    voteImage: StorageString = StorageString{},
    voteOptions: StorageMap<u64, str[3]> = StorageMap{},
    optionCount: u64 = 0,
    votes: StorageMap<u64, u64> = StorageMap{},
}

impl VotingContract for Contract {

    
    #[storage(read, write)]
	fn add_vote_option(optionName: str[3]) -> u64 {
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
        let mut currentVoteCount: u64 = storage.votes.get(voteOption).try_read().unwrap();
        currentVoteCount = currentVoteCount + 1;
        storage.votes.insert(voteOption, currentVoteCount);
        return currentVoteCount;
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