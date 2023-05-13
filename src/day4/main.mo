import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";
import Principal "mo:base/Principal";

actor class MotoCoin() {

  public type Account = Account.Account;

  let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  // Returns the name of the token
  public query func name() : async Text {
    "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    "MOC";
  };

  // Returns the total number of tokens on all accounts
  public query func totalSupply() : async Nat {
    var sum = 0;
    for (val in ledger.vals()) {
      sum += val;
    };
    sum;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async Nat {
    Option.get(ledger.get(account), 0);
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    if (from == to) {
      return #err("Not valid");
    };
    if (Option.get(ledger.get(from), 0) < amount) {
      return #err("Not enough balance");
    };
    ledger.put(to, Option.get(ledger.get(to), 0) + amount);
    ledger.put(from, Option.get(ledger.get(from), 0) - amount);
    #ok;
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {

    let motokoCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };
    try {
      let studentList : [Principal] = await motokoCanister.getAllStudentsPrincipal();
      //Definir un objeto de tipo account
      for (index in studentList.vals()) {
        let student : Account = { owner = index };
        ledger.put(student, Option.get(ledger.get(student), 0) + 100);
      };
      #ok;
    } catch (err) {
      #err("error in the principals");
    };
  };
};
