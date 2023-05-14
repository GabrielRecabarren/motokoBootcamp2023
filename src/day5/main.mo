import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";


import Type "Types";
import Option "mo:base/Option";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  stable var entries : [(Principal, StudentProfile)] = [];

  // STEP 1 - BEGIN
  var studentProfileStore = HashMap.fromIter<Principal, StudentProfile>(entries.vals(), 0, Principal.equal, Principal.hash);

  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    try {
      #ok(studentProfileStore.put(caller, profile));

    } catch (err) {
      #err("ERROR");
    };
  };

  public shared query func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    try {
      switch (studentProfileStore.get(p)) {
        case (?std) {
          #ok(std);
        };
        case (null) {
          #err("Not valid Profile");
        };
      };
    } catch (err) {
      #err("Error");
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    try {
      #ok(studentProfileStore.put(caller, profile));
    } catch (err) {
      #err("ERROR");
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    try {
      switch (studentProfileStore.get(caller)) {
        case (?std) {
          #ok(studentProfileStore.delete(caller));
        };
        case (null) {
          #err("Not valid Profile");
        };
      };
    } catch (err) {
      #err("Error");
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult{
    let calculator : calculatorInterface = actor(Principal.toText(canisterId));
    try{
      let resetResult = await calculator.reset();
      if(resetResult != 0){
        return #err(#UnexpectedValue("Reset function is wrong"));
      };
      let addResult = await calculator.add(1);
      if(addResult != 1){
       return #err(#UnexpectedValue("Add function is wrong"));
      };
      let subResult = await calculator.sub(1);
      if(resetResult != 0){
        return #err(#UnexpectedValue("Sub function is wrong"));
      };  
     #ok();
    }catch(err){
     #err(#UnexpectedError("ERROR: " # Error.message(err)));
    }; 
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public shared func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    try{
      let IC0 = actor("aaaaa-aa") : actor {
        //canister_Status = es la interfaz de IC0.
        canister_status : { canister_id : Principal } -> async {cycles : Nat};
      };

      let h = await IC0.canister_status({canister_id = canisterId});
      return false;
    } catch(err){
       let controllers: [Principal] = parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(err));
      return not ((Array.find<Principal>(controllers, func(id: Principal){id == p})) == null);
    };    
  };

    func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

    public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
        let isItTheOwner : Bool = await verifyOwnership(canisterId, p);
        if (isItTheOwner) {
            let canisterTest : Type.TestResult = await test(canisterId);
            switch (canisterTest) {
                case (#ok()) {
                    var hasProfile = studentProfileStore.get(p);
                    switch (hasProfile) {
                        case (?studentProfile) {
                            let graduatedProfile = {
                                team = studentProfile.team;
                                name = studentProfile.name;
                                graduate = true;
                            };
                            studentProfileStore.put(p, graduatedProfile);
                            return #ok();
                        };
                        case (null) {
                            return #err("The principal has not a registered profile");
                        };
                    };
                };
                case (#err(_)) {
                    return #err("The canister does not pass the test");
                };
            };
        } else {
            return #err("The caller isn't the owner of the canister");
        };
    };


 
 //Persistencia del HashMap
  system func preupgrade() {
    entries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    entries := [];
  };
};
