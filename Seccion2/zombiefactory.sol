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

    // uint => id マップ。ゾンビのオーナーをトラックするマッピング
    mapping (uint => address) public zombieToOwner;
    mapping (address =>uint) ownerZombieCount;

    // _で始める引数が、通例。
    // Private にしないと、誰でも関数を見れる様になる
    //   → _で関数を始めるのが通例。基本的にはPrivateにする
    // 関数修飾子 → view → 読み取り専用
    //          → pure → アプリ内のデータにすらアクセス不可
    function _createZombie (string _name, uint _dna) internal{
        uint id = zombies.push(Zombie(_name, _dna)) -1;
        // msg.sender は、その関数を呼び出したユーザーのアカウントを取得する
        // マップのキーを指定して、キーに対してValueを格納する。
        zombieToOwner[id] = msg.sender;
        // ++ で、 ownerZombieCount の初期値 uint を uint = uint + 1;
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint){
        // keccak256() を使用してString をハッシュ化して比較やキャストしないとエラーになる。
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        //  ゾンビのDNA乱数を16桁になるように変換
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        // ゾンビを作成 ＋ DNAの乱数を格納
        _createZombie(_name, randDna);
    }
}

