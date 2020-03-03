pragma solidity >=0.4.21 <0.7.0;

import "./Ownable.sol";

contract TallyLock is Ownable {

    event LogDocumentSigned(address _validator, string _hash);
    event LogValidatorAdded(address _validator);
    event LogValidatorRemoved(address _validator);
    /**
     *  Mapping of validators added by the Owner
     */
    mapping(address => bool) private _validators;

    /**
    * Mapping of document hashes that map to the "Signature Bundle" in IPFS
    */
    mapping(string => string) public _documentsToSignatureBundle;

    /**
    * Mapping of validator's address to hashes of documents that have been signed with this address.
    */
    mapping(address => string[]) private _validatorToDocuments;

    modifier onlyValidator() {
        require(_validators[msg.sender], "The sender must be a validator");
        _;
    }

    function addValidator(address _validator) public onlyOwner {
        require(_validator != address(0x0), "Cannot add 0x0 address as validator");
        _validators[_validator] = true;
        emit LogValidatorAdded(_validator);
    }

    function removeValidator(address _validator) public onlyOwner {
        delete _validators[_validator];
        emit LogValidatorRemoved(_validator);
    }

    function getSignatureBundleUrl(string memory _documentHash) public view returns(string memory) {
        return _documentsToSignatureBundle[_documentHash];
    }

    function signDocument(string memory _documentHash, string memory _bundleUrl) public onlyValidator {
        require(bytes(_documentHash).length > 0, "Document hash cannot be empty");
        require(bytes(_bundleUrl).length > 0, "Singnature Bundle URL cannot be empty");

        _documentsToSignatureBundle[_documentHash] = _bundleUrl;
        _validatorToDocuments[msg.sender].push(_documentHash);
        emit LogDocumentSigned(msg.sender, _documentHash);
    }
}