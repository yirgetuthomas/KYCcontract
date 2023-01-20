//SPDX-License-Identifier: MIT
pragma solidity ^0.5.9;

contract KYC{
    
    address Admin;

    constructor() public {
        Admin = msg.sender;
    }
    struct Customer {
        string userName;   
        string data;  
        address bank;
        bool kycStatus;
        uint256 Downvotes;
        uint256 Upvotes;
    }
    
    struct Bank {
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
    }

    struct KYCRequest {
        string userName;   
        string data;  
        address bank;
    }

    mapping(string => Customer) customers;

    mapping(address => Bank) banks;

    mapping(string => KYCRequest) kycrequests;

    address[] allBanks;
   
    modifier isAdmin(address _admin) {
        require(msg.sender == _admin);
        _;
    }
    
    function addCustomer(string memory _userName, string memory _customerData) public {
        require(customers[_userName].bank == address(0), "Customer is already present, please call modifyCustomer to edit the customer data");
        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
    }

    function viewCustomer(string memory _userName) public view returns (string memory, string memory, address, uint256, uint256, bool) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank, customers[_userName].Upvotes, customers[_userName].Downvotes, customers[_userName].kycStatus);
    }
    
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].data = _newcustomerData;
    }  

    function addKYCRequest(string memory _userName) public {
         require(customers[_userName].bank != address(0), "Customer is not added in the bank database yet");
         kycrequests[_userName].userName = _userName;
         kycrequests[_userName].data = customers[_userName].data;
         kycrequests[_userName].bank = msg.sender;
    } 
    
    function removeKYCRequest(string memory _userName) public {
        require(kycrequests[_userName].bank != address(0), "There is no KYC request with this name");
         delete kycrequests[_userName];
    }
    
    function upVote(string memory _userName) public {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].Upvotes++;
    }

    function downVote(string memory _userName) public {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].Downvotes++;
    }
    
    function getBankComplaints(address _bankAddress) public view returns(uint256){
       require(banks[_bankAddress].ethAddress != address(0), "There is no bank with this bank address");
       return (banks[_bankAddress].complaintsReported);
    }

    function viewBankDetails(address _bankAddress) public view returns (uint256, string memory, address, bool) {
      require(banks[_bankAddress].ethAddress != address(0), "There is no bank with this bank address");
      return (banks[_bankAddress].complaintsReported, banks[_bankAddress].name, banks[_bankAddress].ethAddress, banks[_bankAddress].isAllowedToVote);

    }  

    function reportBank(address _bankAddress) public {
        require(banks[_bankAddress].ethAddress != address(0), "There is no bank with this bank address");
        require(allBanks.length >= 5, "number of banks is less than 5");
        banks[_bankAddress].complaintsReported++;
        if(banks[_bankAddress].complaintsReported >  allBanks.length/3) {
         banks[_bankAddress].isAllowedToVote = false;
        }
        
    } 

    function addBank(string memory _bankName, string memory _bankRegNumber, address _bankAddress) public isAdmin(Admin){
        require(banks[_bankAddress].ethAddress == address(0), "There is a bank with this bank address");
        banks[_bankAddress].name = _bankName;
        banks[_bankAddress].ethAddress = _bankAddress;
        banks[_bankAddress].regNumber = _bankRegNumber;
        banks[_bankAddress].complaintsReported = 0;
        banks[_bankAddress].isAllowedToVote = true;
        allBanks.push(_bankAddress);
    }
    
    function bankIsAllowedToVote(address _bankAddress, bool _isAllowedToVote) public isAdmin(Admin) {
        require(banks[_bankAddress].ethAddress != address(0), "There is no bank with this bank address");
        banks[_bankAddress].isAllowedToVote = _isAllowedToVote;
    }

    function removeBank(address _bankAddress) public isAdmin(Admin) {
        require(banks[_bankAddress].ethAddress != address(0), "There is no bank with this bank address");
        delete banks[_bankAddress];
    }

    function setKYCStatus(string memory _userName) public {
        require(allBanks.length >= 5, "number of banks is less than 5");
        if(customers[_userName].Upvotes > customers[_userName].Downvotes && customers[_userName].Downvotes < allBanks.length/3) {
          customers[_userName].kycStatus = true;
        } else customers[_userName].kycStatus = false;
    }

}

