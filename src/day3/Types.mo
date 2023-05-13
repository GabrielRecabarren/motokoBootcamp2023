import Principal "mo:base/Principal";
module {
  //1.Definimos un tipo de variante llamado Content que representa el tipo de contenido de los mensajes que pueden ser publicados en el muro.
  public type Content = {
    #Text : Text;
    #Image : Blob;
    #Video : Blob;
  };

  public type Message = {
    content : Content;
    vote : Int;
    creator : Principal;
  };
};
