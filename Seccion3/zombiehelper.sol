pragma solidity ^0.8.0;

import "./zombiefeeding.sol";

/**
    View 関数はガスコストが不要。→ ブロックを参照するだけだから。
    →外部から呼び出されるときのみ、ノーコスト。 関数から呼び出すにはガスがかかる。
    storage -> ブロックチェーンに書かれるので、伸びる程、容量が大きくなる
    → external view の方が低コストになる。 → ユーザーに消費させなくてよくなる。
    memory → インスタンス化して生成し、必ずサイズを指定する
 */

/**
    @dev  ゾンビが一定のレベルに達したら、何か特別な能力を身につけるようにする
 */
contract ZombieHelper is ZombieFeeding {
    /**
        @param _zombieId -> ゾンビのインデックス
        zombiefactory.sol の zombies配列から、Zomibie構造体をGetし、レベルを取り出す
     */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(
        uint _zombieId,
        string memory _newName
    ) external aboveLevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(
        uint _zombieId,
        uint _newDna
    ) external aboveLevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    /**
        @dev マップを作ってownerToZombies[owner].push(zombieId) をやると
            配列に順次格納するので、配列内のゾンビの移動があった場合に 1つ動かすと 19個動かしたり
            しなくちゃならない。 → ガスコストが大幅にかかる。

            view関数は外部から呼び出した時にガスコストがかからないから、
            getZombiesByOwner内でforループを使ってそのオーナーのゾンビ軍団の配列を
            作ってしまえばいい。 そうすればtransfer関数はstorage内の配列を並び替える
            必要がないため安く抑えられるし、直感的ではないにしろ全体のコストも抑えられる。
     */
    function getZombiesByOwner(
        address _owner
    ) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            // owner == address
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}
