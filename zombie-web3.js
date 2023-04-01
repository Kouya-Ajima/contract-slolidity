// コントラクトへアクセス ############
var abi; //コンパイラー
var ZombieFactoryContract = web3.eth.contract(abi);
var contractAddress; // Ethereumにデプロイした、コントラクトのアドレス
// ZombieFactory変数で、上記コントラクトの Public関数・event にアクセスできるようにする。
var ZombieFactory = ZombieFactoryContract.at(contractAddress);

// ボタンをクリックしたらevent発生
$("#outButton").click(function (e) {
    var name = $("#nameInput").val();
    // ゾンビのID、Name,DNA を作成して、コントラクトで event を発生させる
    ZombieFactory.createRandomZombie(name);
});

// コンスタントから event を受け取る
var evnet = ZombieFactory.NewZombie(function (erro, result) {
    if (erro) return;
    // generateZombie に event の結果を引数で渡す。
    generateZombie(result.zombieId, result.name, result.dna);
});

function generateZombie(id, name, dna) {
    let dnastr = String(dna);
    // if lenght < 16 , then add "0"
    while (dnastr.length < 16) {
        dnastr = "0" + dnastr;
    }

    let zombieDetails = {
        // 最初の2桁は頭の部分だ。頭部は7種類用意してあるから、%7して
        // 0から6の番号を取得したら、そこに1を足して1から7にするのだ。
        // これを基にして、"head1.png" から"head7.png"までの
        // 画像ファイルを用意する部分だ：
        headChoice: (dnaStr.substring(0, 2) % 7) + 1,
        // 次の2桁は目の部分だ。11種類用意してあるぞ：
        eyeChoice: (dnaStr.substring(2, 4) % 11) + 1,
        // シャツの部分は6種類用意してある：
        shirtChoice: (dnaStr.substring(4, 6) % 6) + 1,
        // 最後の6桁は色の部分だ。 CSSのフィルタを使用して更新できる。
        // 360度の色相回転（hue-rotate)を使うぞ：
        skinColorChoice: parseInt((dnaStr.substring(6, 8) / 100) * 360),
        eyeColorChoice: parseInt((dnaStr.substring(8, 10) / 100) * 360),
        clothesColorChoice: parseInt((dnaStr.substring(10, 12) / 100) * 360),
        zombieName: name,
        zombieDescription: "A Level 1 CryptoZombie",
    };
    return zombieDetails;
}
