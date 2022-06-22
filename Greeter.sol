
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";



contract Greeter {
    
    string private greeting;
    uint private offertaMax ;
    address payable public proprietario; //puo ricevere ETH e puo essere visto pubblicamente dallo smart contract
    address payable public offerenteMax; //puo ricevere ETH e puo essere visto pubblicamente dallo smart contract
    mapping(address => uint) public offerte; //mappa <address, uint> degli offerenti e delle loro relative offerte
    uint bloccoInizio;
    uint bloccoFine;
    string public hashIpfs; //TO_DO Utilizzando un nodo IPFS è possibile decentralizzare i file relativi di una asta (contratti, opere digitali0)

    enum State {iniziata, in_corso, terminata, cancellata} State public statoAsta;



    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
        statoAsta = State.in_corso;
        proprietario = payable(msg.sender);
        bloccoInizio = block.number;
        bloccoFine = bloccoInizio + 80640; //la durata del contratto è fissata di default a due settimane (un blocco nuovo viene genereato ogni ~15 secondi)
        hashIpfs = ""; //TO_DO
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }

    //modificatori delle function
    modifier notProprietario(){
        require(msg.sender != proprietario);
        _;
    }

    modifier astaIniziata{
        require(block.number >= bloccoInizio);
        _;
    }

    modifier astaNotTerminata{
        require(block.number <= bloccoFine);
        _;
    }

    modifier soloProprietario(){
            require(msg.sender == proprietario);
            _;
    }




    function setOfferta() public payable notProprietario astaIniziata astaNotTerminata{
        
           require(statoAsta == State.in_corso);
           require (msg.value > offertaMax); 
           offerte[msg.sender] = msg.value;
            offertaMax = msg.value;
           offerenteMax = payable(msg.sender);
          
    }


    function getOfferenteMax() public view returns(address){
        return offerenteMax;
    }

    function getOfferta() public view returns(uint){
        return offertaMax;
    }
    

    function cancellaAsta() public soloProprietario{
        statoAsta = State.cancellata;
    }


    function terminaAsta() public soloProprietario{
        statoAsta = State.terminata;
    }


    function fineAsta() public{
        require (statoAsta == State.cancellata || block.number > bloccoFine);
        require ( msg.sender == proprietario || offerte[msg.sender] >0); 


        address payable indirizzo;
        uint value;

        if (statoAsta == State.cancellata){
            indirizzo = payable(msg.sender);
            value = offerte[msg.sender];
        }
        else{ //se l'asta si è conclusa con successo
            if ( msg.sender == proprietario){
                indirizzo = proprietario;
                value = offertaMax;
            }
            else{
                if ( msg.sender == offerenteMax){
                    indirizzo = offerenteMax;
                    value = offerte[msg.sender] - offertaMax;
                }

                else{
                    indirizzo = payable(msg.sender);
                    value = offerte[msg.sender];
                }
                
            }
        }

        indirizzo.transfer(value);
    }

}



