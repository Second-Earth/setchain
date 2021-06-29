pragma solidity ^0.4.11;

contract testencrypt {
    
   function myencode() external returns (uint256 len){     
      bytes memory mycode = "Hello, world.";
      bytes memory pubkey = "04b9ac0a260e212b3b889009dfd1e827c1c096d609aa110e67a62a2f31b1e5bf3ff64c28648e8da60b1dc27e34e7b8cdeeda99c9524669bbd97b41d94990a19bb0";
      bytes memory aa = new bytes(10);
      len = cryptocalc( mycode,pubkey,aa,0);
      return len;
    }

   function mydecode() external returns (uint256 len){   
      bytes memory mycode = "Hello, world.";  
      bytes memory prikey = "289c2857d4598e37fb9647507e47a309d6133539bf21a8b9cb6df88fd5232032";
      bytes memory aa = new bytes(10);
      len = cryptocalc( mycode,prikey,aa,1);
      return len;
    }
    
    
}
