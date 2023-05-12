import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Order "mo:base/Order";

actor class StudentWall() {

    type Message = Type.Message;
    type Content = Type.Content;

    //2.Define una variable llamada messageId que sirve como un contador continuamente creciente, manteniendo un registro del total de mensajes publicados.
    var messageId : Nat = 0;

    //Wall
    //3. Crea una variable llamada wall, que es un HashMap diseñado para almacenar mensajes. En este muro, las claves son de tipo Nat y representan los ID de los mensajes, mientras que los valores son de tipo Message
    var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

    // Add a new message to the wall
    //4. Implementa la función writeMessage, que acepta un contenido c de tipo Content, crea un mensaje a partir del contenido, lo agrega al muro y devuelve el ID del mensaje
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        //1.Auth
        //2.Prepare data
        let id : Nat = messageId;
        messageId += 1;

        //3. Create Post
        let post : Message = { content = c; vote = 0; creator = caller };
        wall.put(id, post);
        //4. Confirmation
        id;
    };

    // Get a specific message by ID
    //5.Implementa la función getMessage, que acepta un messageId de tipo Nat y devuelve el mensaje correspondiente envuelto en un resultado Ok. Si el messageId es inválido, la función debe devolver un mensaje de error envuelto en un resultado Err.
    public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        //1.Auth
        //2.Query data
        let post : ?Message = wall.get(messageId);
        //3. Return request Message or null
        switch (post) {
            case (null) {
                #err("There is not a valid post");
            };
            case (?post) {
                #ok(post);
            };
        };
    };

    // Update the content for a specific message by ID
    //6.Implementa la función updateMessage, que acepta un messageId de tipo Nat y un contenido c de tipo Content, y actualiza el contenido del mensaje correspondiente. Esto solo debe funcionar si el llamador es el creator del mensaje. Si el messageId es inválido o el llamador no es el creator, la función debe devolver un mensaje de error envuelto en un resultado Err. Si todo funciona y el mensaje se actualiza, la función debe devolver un valor de unidad simple envuelto en un resultado Ok.
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
        //1.Auth
        //2.Query data
        let post : ?Message = wall.get(messageId);
        //3.Validate
        switch (post) {
            case (null) {
                #err("This is not a valid message");
            };
            case (?currentPost) {
                //4. Update new data
                let updatedPost : Message = {
                    content = c;
                    vote = currentPost.vote;
                    creator = currentPost.creator;
                };
                //5. Update post
                //6.Return Succes
                wall.put(messageId, updatedPost);
                #ok();
            };
        };
    };

    // Delete a specific message by ID
    public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        //1.Auth
        //2.Query data
        let post : ?Message = wall.get(messageId);

        //3.Validate
        switch (post) {
            case (null) {
                #err("This is not a valid message");
            };
            case (?currentPost) {
                ignore wall.remove(messageId);
                #ok();
            };
        };
    };

    // Voting
    public func upVote(messageId : Nat) : async Result.Result<(), Text> {
        switch (wall.get(messageId)) {
            case (null) {
                #err("There is not a valid post");
            };
            case (?currentPost) {
                let newMsg : Message = {
                    content = currentPost.content;
                    vote = currentPost.vote + 1;
                    creator = currentPost.creator;
                };
                wall.put(messageId, newMsg);
                #ok();
            };
        };
    };

    public func downVote(messageId : Nat) : async Result.Result<(), Text> {
        switch (wall.get(messageId)) {
            case (null) {
                #err("There is not a valid post");
            };
            case (?currentPost) {
                let newMsg : Message = {
                    content = currentPost.content;
                    vote = currentPost.vote - 1;
                    creator = currentPost.creator;
                };
                wall.put(messageId, newMsg);
                return #ok();
            };
        };
    };

    // Get all messages
    public func getAllMessages() : async [Message] {
        let msgBuffer = Buffer.Buffer<Message>(0);
        for (msg in wall.vals()) {
            msgBuffer.add(msg);
        };
        Buffer.toArray(msgBuffer);
    };

    type Order = Order.Order;

    func compareMessage(m1 : Message, m2 : Message) : Order {

        if (m1.vote == m2.vote) {
            return #equal();
        };
        if (m1.vote > m2.vote) {
            return #less();
        };
        #greater;
    };

    // Get all messages ordered by votes
    public func getAllMessagesRanked() : async [Message] {
        let array : [Message] = Iter.toArray(wall.vals());
        Array.sort<Message>(array, compareMessage);
    };
};
