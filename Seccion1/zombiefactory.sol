pragma solidity ^0.8.0;

contract ZombieFactory {

    // イベントを用意 → Gorutine のチャネルの送信みたいなもの。
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    // Public → GetterをSolidityが自動作成する。
    Zombie[] public zombies;

    // _で始める引数が、通例。
    // Private にしないと、誰でも関数を見れる様になる
    //   → _で関数を始めるのが通例。基本的にはPrivateにする
    // 関数修飾子 → view → 読み取り専用
    //          → pure → アプリ内のデータにすらアクセス不可
    function _createZombie (string _name, uint _dna) private{
        uint id = zombies.push(Zombie(_name, _dna)) -1;
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view 
        returns (uint){
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        //  ゾンビのDNA乱数を16桁になるように変換
        uint randDna = _generateRandomDna(_name);
        // ゾンビを作成 ＋ DNAの乱数を格納
        _createZombie(_name, randDna);
    }
}