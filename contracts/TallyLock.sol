pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/GSN/GSNRecipient.sol";


contract TallyLock is Ownable, GSNRecipient {

    /**
     *  Mapping of validators added by the Owner
     */
    mapping(address => bool) private _validators;

    /**
    * Mapping of document hashes that map to the "Signature Bundle" in IPFS
    */
    mapping(string => string) private _documentsToSignatureBundle;

    /**
    * Mapping of validator's address to hashes of documents that have been signed with this address.
    */
    mapping(address => string[]) private _validatorToDocuments;

    modifier onlyValidator() {
        require(_validators[_msgSender()], "The sender must be a validator");
        _;
    }

    function addValidator(address _validator) public onlyOwner {
        require(_validator != address(0x0), "Cannot add 0x0 address as validator");
        _validators[_validator] = true;
    }

    function removeValidator(address _validator) public onlyOwner {
        delete _validators[_validator];
    }

    function getSignatureBundleUrl(string memory _documentHash) public returns(string memory) {
        return _documentsToSignatureBundle[_documentHash];
    }

    function signDocument(string memory _documentHash, string memory _bundleUrl) public onlyValidator {
        require(bytes(_documentHash).length > 0, "Document hash cannot be empty");
        require(bytes(_bundleUrl).length > 0, "Singnature Bundle URL cannot be empty");

        _documentsToSignatureBundle[_documentHash] = _bundleUrl;
        _validatorToDocuments[_msgSender()].push(_documentHash);
    }

     //META-Transactions
    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    ) external view returns (uint256, bytes memory) {
        if(_validators[_msgSender()]){
            return _approveRelayedCall();
        }else{
            return _rejectRelayedCall();
        }
    }
}