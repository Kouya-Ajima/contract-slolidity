pragma solidity ^0.8.0;

import "./zombiefactory.sol";

/** インターフェース → 他人のコントラクトから呼び出し、呼び出されする関数。
    function の returnsステートメントの後ろに {} を付けない。
 */
interface KittyInterface {
    // external → ブロックの外からしか呼び出せない関数
    // Solidity では、複数のリターンを返して良い
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

contract ZombieFeeding is ZombieFactory {
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // インターフェースのメソッドの引数に同じ型の値を渡してインターフェースを作成する。
    KittyInterface kittyContract = KittyInterface(ckAddress);

    // _targetDna → 捕食する人間のDna （クリプトキティインターフェースの、キティ→ genes値）
    function feedAndMultiply(
        uint _zombieId,
        uint _targetDna,
        string memory _species
    ) internal {
        // ゾンビIDがすでにオーナーが存在するものであれば処理を抜ける
        require(msg.sender == zombieToOwner[_zombieId]);
        // 【不明点】zombies[_zombieId] で Zombie が取得できる？ IDで取得できる？
        // _zombieIdはインデックス？
        Zombie storage myZombie = zombies[_zombieId];
        _targetDna = _targetDna % dnaModulus;
        // 人間とゾンビの平均値のDnaを算出
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // Stirringの比較はハッシュ化する。 → Kitty と同じなら、ゾンビを猫の特徴に変える。
        if (keccak256(bytes(_species)) == keccak256("kitty")) {
            // 334455 - 55 + 99 == 334499
            newDna = newDna - (newDna % 100) + 99;
        }
        // プライベート関数 → internal に変える → コンストラクト内部からでしか呼び出せなくなる。
        //   → Privateの少しゆるい版。
        _createZombie("NoName", newDna);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        // n 番目の引数だけを受け取る方法
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
