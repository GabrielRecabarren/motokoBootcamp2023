import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Debug "mo:base/Debug";

import Type "Types";
import Nat "mo:base/Nat";

actor class Homework() {

  type Homework = Type.Homework;

  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    let homeworkId = homeworkDiary.size();
    homeworkDiary.add(homework);
    homeworkId;
  };

  // Get a specific homework task by id
  public shared query func getHomework(homeworkId : Nat) : async Result.Result<Homework, Text> {
    if (homeworkId >= homeworkDiary.size()) {
      return #err("Homework not found");
    };
    return #ok(homeworkDiary.get(homeworkId));

  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(homeworkId : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (homeworkId >= homeworkDiary.size()) {
      return #err("not implemented");
    };
    return #ok(homeworkDiary.put(homeworkId, homework));
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(homeworkId : Nat) : async Result.Result<(), Text> {
    if (homeworkId >= homeworkDiary.size() or homeworkId < 0) {
      return #err("Index is not valid");
    };
    var homeworkSelected = {
      title = homeworkDiary.get(homeworkId).title;
      description = homeworkDiary.get(homeworkId).description;
      dueDate = homeworkDiary.get(homeworkId).dueDate;
      completed = true;
    };
    return #ok(homeworkDiary.put(homeworkId, homeworkSelected));
  };
  // Delete a homework task by id
  public shared func deleteHomework(homeworkId : Nat) : async Result.Result<(), Text> {
    if (homeworkId >= homeworkDiary.size() or homeworkId < 0) {
      return #err("Index is not valid");
    };
    ignore homeworkDiary.remove(homeworkId);
    return #ok();
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    var clone = Buffer.clone(homeworkDiary);
    clone.filterEntries(func(_, status) = status.completed == false);
    return Buffer.toArray(clone);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    var clone = Buffer.clone(homeworkDiary);
    clone.filterEntries(func(_, status) = status.title == searchTerm or status.description == searchTerm);
    return Buffer.toArray(clone);
  };
};
