import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";

module {
  public type Account = {
    owner : Principal;
  };

  public func accountsEqual(lhs : Account, rhs : Account) : Bool {
    Principal.equal(lhs.owner, rhs.owner);
  };

  public func accountsHash(lhs : Account) : Nat32 {
    Principal.hash(lhs.owner);
  };

  public func accountBelongToPrincipal(account : Account, principal : Principal) : Bool {
    Principal.equal(account.owner, principal);
  };

  public type Error = {
    #Anonymous;
    #NotAnAdmin;
    #UnexpectedError : Text;
  };

};
