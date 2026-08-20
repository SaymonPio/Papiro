#!/usr/bin/env node
// Fase 3B-1 — Língua Portuguesa (Saneamento de Referências a Linhas/Lacunas e Higiene de OCR)
// Universo auditado: 162 questões de Língua Portuguesa (materia_id = 6).
// Escopo do lote de alteração (14 questões críticas):
//   - ID 66: Enunciado autossuficiente com palavras transcritas (cora...em - ameni...ar - fa...cínio). Gabarito E preservado.
//   - ID 70: Enunciado autossuficiente com os 3 trechos de crase transcritos. Gabarito D preservado.
//   - ID 115: Enunciado autossuficiente com os 5 trechos de crase da BM 2022. Gabarito A preservado.
//   - ID 119: Enunciado autossuficiente para ortografia dos 4 vocábulos das opções. Gabarito A preservado.
//   - ID 120: Enunciado autossuficiente com os 3 trechos de regência e pronomes relativos. Gabarito A preservado.
//   - ID 121: Enunciado sem referências cegas a linhas, focado na semântica de conectivos. Gabarito B preservado.
//   - ID 321: Enunciado com padronização tipográfica das lacunas (de...empenho - e...igente...). Gabarito B preservado.
//   - ID 324: Enunciado autossuficiente de coesão referencial sem numeração de linha solta. Gabarito E preservado.
//   - ID 328: Enunciado autossuficiente com os 3 trechos de crase do CBMRS 2025. Gabarito D preservado.
//   - ID 329: Enunciado autossuficiente com as 3 palavras de ortografia (dei...ar - extin...ão - utili...ar). Gabarito C preservado.
//   - ID 330: Enunciado higienizado em linha única sem erro de OCR (e...tremidades). Gabarito E preservado.
//   - ID 333: Enunciado de coesão referencial limpo sem quebras manuais e alinhado ao texto. Gabarito D preservado.
//   - ID 334: Enunciado autossuficiente para substituição da adversativa "mas". Gabarito C preservado.
//   - ID 689: Enunciado com padronização das lacunas ortográficas. Gabarito B preservado.
//
// 148 questões intocadas: preservadas 100% byte a byte.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase3b1_portugues_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase3b1_portugues_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes capturados ao vivo do banco de produção (162 questões de Língua Portuguesa):
const HASH_QUESTAO_ANTES = {
  "6":"14bb8c74728533d4db75b194db6e290d","16":"f06ca492184cc59856d0f6780a6b0939","17":"a61df0011cf39ca9cb771919435d5361","18":"f8ff9fb2b1475892b95f1b6f06d08dad","34":"19a4b06aeeac3b4f3a5d685730473e6b","65":"cc2f3a4e9d2af0404dfdfd0f213865a7","66":"f558b0ad5d4a4f828fa93ba4189db6db","67":"5b5adcff96792b38c31b01e41f87e88c","68":"220a6aebc8a714c817b0bb308166ea20","69":"c3f737a5c26f0f53cd07774c7ef0ebce","70":"22b6ab10a4534c9a1f565d669cbc96fc","71":"eed42476b400d22a90ec4836acd2477f","72":"c5326698d6daba71b8b3f3dff1d17b6c","73":"870de41812ea51181cc7905d613c6cdf","114":"58d49f0d54b7dae0d1da827b8c28c8bc","115":"690a863614c9ee268b73e832b8146fa2","116":"70ded797e8c0d2944237112b767aa76b","117":"7fe43c361f52c9f098eaf931c0bfee0e","118":"6526554dcd7c585d24220e3e2605441d","119":"00359a25dec93c03cfc8a5275b9b7fe6","120":"0f3c122ebd380c0d5f670fed903e2a06","121":"5d7ea182b7407e65ea700d67b44e6b9f","122":"9ecbf34e3af451ced73a2d1371bb8204","123":"8e591cd106188d99173193aa28dc120b","216":"104560ac0459965041f90e56c9a078b3","217":"ce1d0950ed66896971d501a845e6e7a3","218":"e78ef380ff229fd6f7fec85a09ad2a2b","219":"93e59de679d1f3d420495a91a2728e03","220":"8b8b0586fbe6b49b04dbf5b69d419086","221":"365850d2f57deffe5bf09fb18edfa9a1","222":"cce3b6381a33d51105c9b0d3788b0bc5","223":"30172c1136674c432961c3cae467500d","224":"7cba416e60194d10f2b32c99e91529ef","225":"bdbe978b0d35dd34d17ab9232867ba97","226":"0aa5d7ae09a8a49c3f910c14ca2b082b","227":"a04eb1e3a2c3cee6e11c3f82d4c8bb71","228":"68ca436ae73707ed3ae9426fd16f8d03","229":"236230f436f9ad7624873188e82375a7","230":"8db91cd7e03a07425ca92d8c651155c1","231":"7ce2fde1e3075fa75ac5f322bd3ecb99","232":"aeef030de2435bcbfc1e9f54e39b581b","233":"ed1a2b7ef3c21c8cec704b317c83e948","234":"eb9127b38fbe83e2270ea84e99144c7c","235":"7fdfa933a23e4fedd4e2b62ab3557a3e","236":"8da25b67c1df91f7bdd0030dad398699","237":"c7d7a92c0705d112967f8f154973eee0","238":"c863ffa84636aa26380565bcaf0b95c3","239":"3fb68bb73f0cb4be259b04598c134289","240":"b683a45aef8523bc8397f3c127762b31","241":"cb0de6f9f2010787199458d48a5799cb","242":"96679042044ef0efd8fa19ee301dcaf7","243":"9ae48d33cdc8745cbded92b6f754d39d","244":"2eb9cd414ff72032f192ebe1d5c3cd27","245":"5325c385fa8e933396f643a1ac96c0ff","273":"71ef2363a3d282939d625e4782ab2aa9","274":"2400fc138e34d01687fbcc8269f29bde","275":"4491f932bbc33db3187cde3389bccab2","276":"6a980f7907a170abf94432da1ab08bf2","277":"aeb47e1ae3b00a01bba1e70f29dfcb3b","278":"a79a45e6c2beac3be265848e3941b1f8","279":"6945be3d7930d0752ba535bbcd6e4453","280":"13e7529620d12755dccca8d543e88e01","281":"eb8c6f1564bc362a86a5eed77bf5d14b","282":"b244b3b485a5bb8c83b0edbaf787a5ad","283":"4f6ee86b17c7928f16391e15a6f8e4be","284":"9f9bdaf61fbb0500b9617841840e0ba9","304":"75bfac8b9009ae8b2c6e3a6c1dba4a4e","305":"0b1beee326f36a4cc54bbd293ffcfedf","306":"2e596766d8b4080812d886391d048a76","307":"7d65ada30e67ab16fef7a3169841ea72","308":"7284434cfe270e1f2b50eed3d7593b8c","316":"532e9da2ecd99685b83664c713a849ed","317":"a7e76ad91261958babd4dda26b6411f3","318":"3c880bae123683d42bb90764549eda03","319":"66a73b9c165b1aed6c79eb40db3fb55e","320":"710073144b81cb9abfd3e2e303afdfa2","321":"8660d18d1eca2ab656a8c4604086d41b","322":"f177f1ed675c14d9a80ef959d2d1b1ab","323":"72c47772ca511c225834ef17f1623220","324":"f4d1ee475bfb474cc196810425f35e28","325":"0000e0f519774afa5079c45a146cb244","328":"cf8a85c9f8f8a7e6cceec665c4e3f994","329":"e5a8514973f9d12f41fb70422b48c25e","330":"503a1766b18c0ec9854c07c7787ca6af","331":"d95cc831eeac87031ea95d0be77ccd36","332":"e93c27bc6afbf580a80727211a4bf51c","333":"a9b6d85a4a1158c309f3ac8fe9cd76c4","334":"347ce0b596feac2fcd1b3d04b1e77e8f","335":"230c6860a68b341d8a7071cdf19dfde9","336":"9b8265375020ef9bfe7c2f69b7299b5c","679":"063cdd66b651f0f91567044369f2e06a","680":"ef1cab56aa82a753f9cb059fa46a80d2","681":"e64e2be9682552baf8ff9ec99b644e08","682":"6f7a4d19fb91380dcc22d750ed7d7e1a","683":"7691f94872f88251bdd93a7db281f8b9","684":"333cea8a3368af654a704763fbc93a6e","685":"955a1c641104302bb9b1fe01006cbac4","686":"4e97e7657368622f8278dc3a5c12f08e","687":"8f3c13750f5b7f8157d50e2c6c81aab4","688":"a066f6bad50467180bc333e0439f20f2","689":"70b65d174c9a54482072a86c45399500","690":"81511d4c7ef51cb1553194480fd47b64","691":"80b3382813f5a683fef6b1baed1ab7f9","692":"3909af1d97ae54039f902b78d03fa990","693":"82ec8f673b5b7f8d918e2ca801830894","744":"d4e4b5a1ef09d0acd307104878adabb2","745":"24238e226ae59913ff9f9a231d6be185","746":"b2ad5ff44f08078e31b98805b9abe55b","747":"86bba2c0181521f08322772bd5140df8","748":"5ef00bdf18e125db34f619a0219f0288","749":"0a4da8d660f3bd0d756bb43b6598d562","750":"cc1feddf97c7b55cbe4e2ddb5b615458","751":"6b251fb036f55566a8376398261807f1","752":"5782c85395ba155876df6123dcf0cd0c","753":"b3f1e3f0db4819837b38f04eae2bd4ce","754":"64acd05518fdbf9b70cc8cb138b73c19","755":"42302cc0b78d35f4cc43e07d7900e018","756":"fdc39389f994484dd8dd996ffe925298","757":"1cf8f47dfa85a5461f6c163084ec79ac","758":"9f3f608b15819870691a7b23538db559","759":"df972335f87d7aa599d1355030d27500","760":"25755fb49a45a532f9df8e7c7d274429","761":"5d7041ef718b8601d07ebf26bd1c9405","762":"bee243cc08fcc98ff43b6fc2dda271e8","763":"f69285a51ba56002a40724cd4fbe4636","764":"cbcece6ff6aa8172bc2bd891964924a4","765":"bc6f3441d675c47bc3a4b2d17e4c037c","766":"575d51f649ea0fc2f12245da69f2b23e","767":"4e81a5bfc9a10b34535e5498e6fb973d","784":"9abd058114409801fd0316bf34cef61c","785":"c82b2a2e3dfb9f7d0ef8aa80539f65e2","786":"619c05d0cd7817e10f10c7d3f508099c","787":"17a6b03670bb2295b43175605fcb81cf","806":"04067d12d2ad362753f9b0c9ad646371","807":"d371eeaa3aa584d4ace098025782335e","808":"49a236e6cea4b81c1c7b7ef4d09e97fe","809":"e31d668f27228187b38a207a62f305c3","810":"e0ce42c7f48bbe0afe72fbeca2b07851","811":"8e531020423ed54e53c3276baa899d59","872":"0e6f6db13c1da4c720551f93116d06d6","873":"119ebc103273df73b1c4046447f91beb","874":"57603c30ec87663ea7e869aeb0ee18ef","875":"25bdf2be016a1240ecf28853a6cb9446","876":"193ee4e8e9586418cafdb4b6f48faea6","877":"ffac650097dba456d464f6605efa2844","878":"dab7d211dfe2566bd4af6e41de50b052","879":"6f819ef9d01405b03b84e85defbec9bc","880":"c0514db781986e70b3250ab02d485407","881":"7ae59450cff84d30faecccb1fc2d31c0","882":"2f1a3bcb4a6201a450086da8a0122ddd","883":"a67c311b4572bf0580788323efa176f0","884":"878af044dbaa04c69d61402773cfbad4","885":"557255dc4a92a0b5fd5664dc344efe84","886":"63d7811ab03ac97aafe45e6fab69e8f6","887":"32407397a7d90c29fea344a7bb6373e0","888":"2e811a7e2fe0114c86dab83a416dfad2","889":"5a4cf550bd927bfffbb51829285e1350","890":"f04e7fcc0cd9ae83413f62492791ea44","891":"4760d8e5381e6ef49faab926bef2bc56","892":"7ca5f929bac281794ab038e481ef6b3b","893":"979e8b2401fd67b391fe0265f3c17276","894":"478aad8ae276fac32cdc5aaa311a1df0"
};

const HASH_EXPLICACAO_ANTES = {
  "6":"d711fe2eb35e6495cfcb63d4b21f44e9","16":"d1f17ac23283bfaa8afb32d9c5adc5d6","17":"e80aa0019deb39b517e233efdfbc0f9a","18":"6bf2234ad7294a3aa0749e1a83ad3f36","34":"1c959848ec72a4cb89c734fdb005b40c","65":"834346d5900df4952deb47e89db27086","66":"aba378ad15a794b7a4f0936d2eb96843","67":"49008d89bb745537c18057300fe0f90f","68":"f625a5af150996ef4f368f2ac993fe49","69":"29a75b645166f94d7ea6c513faeafa43","70":"1a0b33cce431f5e44468b8ed5f8482dd","71":"0a9e098125f4474a6f73550d0b66a36d","72":"34e4bf4642dc89a87d0ca9b28504a41f","73":"9ac04c9d7cd7071fc3e9812940d4001c","114":"3f08e1f684ad1c79f69b4908e5813fd4","115":"df0553d90db08a0959fdb599459eebaf","116":"bcc908ad443d02b033c2eaf18ef317a1","117":"3bae1be4d3b803b1fb0d7b248a115cee","118":"f380843177b269a361e9c40aa9e488a1","119":"8983066c29c954bcabfd8afc648497de","120":"7bdc9146c1bd76847b4d98c5d35f1839","121":"3a3eaf2f3d69a6b0ce2cda8acb777272","122":"d3d28dac90c1e18c1e77813227c3c2f4","123":"89f5ac2b427b29d233d9ea8353620b17","216":"e67fb20cf2eefaa0c6a370a14bd70b99","217":"5d7900dee1ea0babe531760f8693b2c4","218":"c3e4efae43c8a89e9d82bbe035ab68be","219":"ed69164acfb339aaeffa163411dc26b4","220":"b1bd9e0214ca79913b7b90d1af5753bb","221":"6f0453a67631fea4b56c67be1e847466","222":"81a2fa19cc62a184ecc9bc3096f4095b","223":"6b43ebe5784eac91f41f4f508b35510e","224":"96d7e80abf0fc87b3c787355f0e7523e","225":"f79040a8c6d5b721fab83dd395c02567","226":"8fd9600da7d75b4dce7348545a9a302e","227":"19a3bf3098234b1e1ce617104195df2e","228":"52abd3f16f7ff49f83b7437b3cc9c3e0","229":"96b01a385e684ea4323d9a057f7d4f61","230":"c8e496f9d6b9340c137a4b0990ac13db","231":"1cba29ef7fd428c3ed7292c3e285eb89","232":"4377e9a4149bb5866538d4efbaca8d5e","233":"255f94cb7887728cab2b07687e1973b7","234":"fd4dd0595fa6f16faa748a1f754c6b90","235":"e35da6fa1c5e5e5b27202de38009f0d5","236":"6e2557341676e2232115b38268e3bc98","237":"7c425f051735c5e90909782c16a2dc32","238":"3c3aca801bc4ae249cc7a75afb024d04","239":"44da2e2c3b232a8a73efc5e13d13d671","240":"d1a93a9e1089302a16f6fcb90529e1bd","241":"8726e76d8d4ec0f3554f7b963d5135e3","242":"d7188ef7d60630d0a735d6087bd26446","243":"63e590798b734b4db51e5f005e4029f3","244":"e5d8a22bfbe87a864ce6a15bb18c3fc2","245":"738caeced73ad65f318ec228a4b10f19","273":"9ed547b4f5c695f16b8aaaa5181a77d6","274":"6f1c2ece83cc81cab1d78bd23f7082f5","275":"13462d04b0ab80951c3ff496a3d6fb12","276":"45cd96b9f6576acdd21d75289abcdb3d","277":"2abfc6b72e03964d12d4a1247a33d8a2","278":"2e46926093c6ade51623a5d5f610bea1","279":"0b0c19cfda26bda668a9e4b28c29246e","280":"587cb63ea4fb2ed047c320ec5474c831","281":"87c8ede24166e323653f385a6b353dee","282":"73e17af7454464a21c3b30906e787412","283":"b7f9665a7b9f84989ac85cff852d7e09","284":"af246006004b3f2c4ab0f4b500ca3ffd","304":"70182ed52437327cc1ed578836de23c9","305":"2c54202cc7e5fa954bacea557a236d35","306":"754266d88d3927bd7e0902d296cadfeb","307":"ad24b7e184fc8595559d603799ad67e3","308":"d97761b5f0c0985db41808ac84d0c691","316":"7311cb7af38b3fde2146deea640f1df2","317":"bd6f1c70a84829093ed88dbf92916229","318":"25951c2bb4f298ba7269b8692083cd36","319":"f1fb7549384758dd817f53f79a15505c","320":"59179a570ec3de3bd2e06e09a78285d8","321":"2cada8c5680b59ed6e0044a9b0dcebfc","322":"561033653c46b26749bdf48506da8f43","323":"9433a50ef68f0b9157efd36c6641af17","324":"82c28d67b9017c1de3c9117c682016f0","325":"023e7cfdd64f67c55a264c4c8b4b7bc4","328":"fe27f58e4a3cbba099c663b7ec2a8ddc","329":"0456f4f166314a3021796faae601c4c4","330":"ee4027eafd05c78dbc6138ed3e9e76cf","331":"e5c2dc784e3ea93ad54f0ef2a0be1d97","332":"00a3e03e83f2d12dc40e9f582aef6e29","333":"b945275da2cbff7f562ee49f4591b304","334":"66d45c708da9f03cc0d1516fadad68da","335":"d9b9d593edbcb5d2773fa874e263fdeb","336":"49317011cf692cfc41bfd2b39f9171c3","679":"dc49a1a3b07b2c05c6e747f409043f3b","680":"a4928e4bde4266c4b4ae51a5e9ec8eda","681":"2b6744715c519e3a8a0fd7ceb817306b","682":"d7a96257c9da0ce403a550d349d8e113","683":"3256310c58239d18ef88003b954dd7df","684":"fb1dca2ba40e6b2f69ddda287f4566b6","685":"70be98ddfe0711b36928ff6b42c2393e","686":"84ce899d79742ea3b8d4306066333e96","687":"41b9f10c03fbb60b6069a7236121ad63","688":"bf3c1bb0509a4d2721f51eb217733fcb","689":"b71c653472996567beb06597f8866214","690":"a80e027523f66dbfeba6da3b7f434813","691":"61f04195a58935a7925fa57ad1687fe0","692":"4e509e4f2fd663f5f9eab46477b733ca","693":"3cbf71958cb7c6fdc1b3786aba0e2eea","744":"008035bc93aa4f40f739d18b6ffc9c04","745":"6897bd55ca1239681952094335dfbdda","746":"dbc1bd270c8cff9e7716cb8b9d9a29a9","747":"251d49a151e7f0f2a75b44bd75371d25","748":"a5744aa22b61d84b0e85b086c8446e4d","749":"dd00f03a8eef9bf3ec3d49eea789e1a5","750":"551c02da22d1d6ac32a2787903291dc5","751":"d966bf38c1860b0961409df020b6d16a","752":"f6049ebb5c37d3d7c07805fecb770153","753":"0de3bf0d715feb1fa8ec0ae7b3a4ca3d","754":"76e86390d4cdd904220ddc63dbdf2f7d","755":"39e65345a4e39aa08c12d7cec6af83d1","756":"db39914df8497b0ef2f50b3dd8e3c90c","757":"c3a15a7c7dd43a07bcd3c821f45b6ecc","758":"9d012ac1ddc164753c104fd7f796234d","759":"176d43787e6e25e18f55fc1619889d78","760":"fc12ebf9326095252348502a38b5a71b","761":"e446d3cc3f4b1dc87f739c3ad71969cd","762":"fafcb233a82394f78e4c6d8369d458ac","763":"731bedcb5354c3c1ea38c2d2e649c6dc","764":"25f897d26a12d2d1881c2dc0b2fb666b","765":"5837a7f737e717bff6b0e0a957a8111b","766":"bb00c310866b27a94524f234923841dc","767":"2d7f4617209adad16a92c8e2645fbd24","784":"2b52269d667989fab275f59bf28c3753","785":"ca414c302293c47362996e04109a23d2","786":"04f966cac86feadc97b84663f8033f04","787":"770a423ac5ea5c732d0aa5cf74bde6ea","806":"c6d3aa0795a592b3ff1e698cd0a72895","807":"dcf0603cf52e3fe7f783f7d0acf2e055","808":"837195bae67fc09aa67d92cb4ea0bf35","809":"e0bec1e2eb881204937def29492e1dfe","810":"e3af7a523423a5578bbd18e1979f711c","811":"19de19eda2e770a177f9abcfc7d11c64","872":"03980e73a166a2d382d3ba5304501a95","873":"4ca6d2d5bbc533aeb142cb162c99dc60","874":"c4ed1f424a3191283728fac86f896786","875":"a24f7ace755be2f97e14fd7810e0bad9","876":"cd7ccc454a29a28e59ef79821c79a03d","877":"ba73497528c2c8f57490fd62d9051b35","878":"718bff9261bd25cb5ec345bb2d1e8747","879":"7d5a59b2a1b56f1371714324ab840da5","880":"daba602de7797247f66c67bc0e83e2aa","881":"3a696aaaab37b7ba91fc9bf9d8f6a08c","882":"11e8d3a10932a70aee77735710d3ed29","883":"0d80479d2955d1de6716f8df122c67d2","884":"df5ae8db3bfd9b9e6f84aaee99ab7b06","885":"56533bb337725c3db6553e32d63da727","886":"f51a3c3c2d434cb0d512d0b7f8fe0115","887":"027b8e6216634f7c09ec2992e086b017","888":"16f8f226e7fc23c6585af0229b602167","889":"fa348275b3446db1fe0663892e6ed0d5","890":"4d706e7f06319dd90e2f6f512bd4778b","891":"e95ab5ff3c99f803d9a61710e4893cd0","892":"f17b7cdbb8235bcc62679e028b90f3cc","893":"658d594ecdd6af2589d326fbea4a4f0d","894":"98f6b13708c430783ed814825182cf0c"
};

const GABARITO_ORDEM = {
  "6":1,"16":1,"17":1,"18":1,"34":3,"65":3,"66":5,"67":2,"68":3,"69":3,"70":4,"71":5,"72":1,"73":1,
  "114":3,"115":1,"116":5,"117":4,"118":1,"119":1,"120":1,"121":2,"122":4,"123":1,"216":1,"217":1,"218":1,
  "219":1,"220":1,"221":1,"222":1,"223":1,"224":1,"225":1,"226":1,"227":1,"228":1,"229":1,"230":1,"231":1,
  "232":1,"233":1,"234":1,"235":1,"236":1,"237":1,"238":1,"239":1,"240":1,"241":1,"242":1,"243":1,"244":1,
  "245":1,"273":1,"274":1,"275":1,"276":1,"277":1,"278":1,"279":1,"280":1,"281":1,"282":1,"283":1,"284":1,
  "304":1,"305":1,"306":1,"307":1,"308":1,"316":4,"317":3,"318":2,"319":1,"320":5,"321":2,"322":4,"323":3,
  "324":5,"325":5,"328":4,"329":3,"330":5,"331":1,"332":4,"333":4,"334":3,"335":3,"336":2,"679":1,"680":4,
  "681":4,"682":5,"683":4,"684":1,"685":4,"686":3,"687":3,"688":5,"689":2,"690":1,"691":1,"692":5,"693":3,
  "744":5,"745":2,"746":5,"747":3,"748":4,"749":1,"750":4,"751":3,"752":1,"753":1,"754":3,"755":3,"756":3,
  "757":5,"758":5,"759":5,"760":5,"761":1,"762":3,"763":2,"764":5,"765":5,"766":4,"767":3,"784":2,"785":3,
  "786":1,"787":5,"806":1,"807":1,"808":2,"809":3,"810":4,"811":2,"872":4,"873":3,"874":2,"875":3,"876":1,
  "877":4,"878":1,"879":5,"880":3,"881":3,"882":2,"883":1,"884":1,"885":2,"886":4,"887":1,"888":2,"889":1,
  "890":3,"891":5,"892":3,"893":2,"894":5
};

const IDS_ALTERADOS = [66, 70, 115, 119, 120, 121, 321, 324, 328, 329, 330, 333, 334, 689];
const IDS_INTOCADOS = Object.keys(HASH_QUESTAO_ANTES).map(Number).filter(id => !IDS_ALTERADOS.includes(id));

// Textos saneados para os 14 itens do escopo:
const ENUNCIADO_NOVO_66 = "Considerando a ortografia das palavras em Língua Portuguesa, assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas nas seguintes palavras retiradas do texto: cora...em – ameni...ar – fa...cínio.";

const ENUNCIADO_NOVO_70 = "Considerando o emprego do acento indicativo de crase, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos seguintes trechos do texto-base:\n\n1. \"...chegar _____ margens da lagoa...\"\n2. \"...trouxe _____ tona a discussão...\"\n3. \"...começou _____ percorrer o caminho...\"";

const ENUNCIADO_NOVO_115 = "Considerando o emprego do acento indicativo de crase na norma-padrão, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos trechos a seguir:\n\n1. \"...em relação _____ juventude...\"\n2. \"...dispostos _____ ouvir...\"\n3. \"...graças _____ dedicação...\"\n4. \"...atribuído _____ pressa...\"\n5. \"...resistência _____ mudanças...\"";

const ENUNCIADO_NOVO_119 = "Assinale a alternativa cujos vocábulos estão todos grafados de forma correta segundo a norma ortográfica vigente da Língua Portuguesa:";

const ENUNCIADO_NOVO_120 = "Considerando o emprego dos pronomes relativos e as regras de regência da norma-padrão, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos trechos a seguir:\n\n1. \"...o cenário _____ nos encontramos...\"\n2. \"...as transformações _____ presenciamos...\"\n3. \"...o autor _____ obra foi citada...\"";

const ENUNCIADO_NOVO_121 = "Avalie as afirmações a seguir sobre o valor semântico e as relações de equivalência de conectivos na Língua Portuguesa:\n\nI. A conjunção temporal \"quando\" pode ser substituída por \"conquanto\" sem alteração de sentido no período.\nII. A conjunção adversativa \"porém\" pode ser substituída por \"entretanto\" sem alteração de sentido.\nIII. A conjunção condicional/integrante \"se\" exprime conformidade, podendo ser substituída por \"porque\".\n\nQuais estão corretas?";

const ENUNCIADO_NOVO_321 = "Considerando a norma ortográfica vigente da Língua Portuguesa, assinale a alternativa que preenche, correta e respectivamente, as lacunas nas seguintes palavras: de...empenho – e...igente – e...gotamento – visuali...ado.";

const ENUNCIADO_NOVO_324 = "Com relação ao emprego de recursos de coesão referencial e pronominal, analise as assertivas a seguir:\n\nI. A expressão anafórica \"esse filho adulto\" refere-se ao próprio personagem em relação aos seus pais, e não ao filho de Pedro.\nII. A locução pronominal relativa \"em que\" pode ser substituída por \"no qual\" sem prejuízo da correção gramatical ou da referência estabelecida.\nIII. O pronome \"delas\" retoma anaforicamente o substantivo \"suposições\", que é posteriormente desdobrado em exemplos.\n\nQuais estão corretas?";

const ENUNCIADO_NOVO_328 = "Considerando o emprego do acento indicativo de crase segundo a norma-padrão, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos seguintes trechos:\n\n1. \"...adaptadas _____ novas necessidades...\"\n2. \"...com relação _____ prevenção...\"\n3. \"...somadas _____ bombas manuais...\"";

const ENUNCIADO_NOVO_329 = "Considerando a ortografia das palavras em Língua Portuguesa, assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas nas seguintes palavras: dei...ar – extin...ão – utili...ar.";

const ENUNCIADO_NOVO_330 = "Considerando o vocábulo \"e...tremidades\", verifica-se que se trata de um ______________, cuja grafia correta se dá com o preenchimento da lacuna pontilhada com a letra ______ e que apresenta como sinônimo contextual adequado o termo ______________. Assinale a alternativa que preenche, correta e respectivamente, as lacunas do trecho acima.";

const ENUNCIADO_NOVO_333 = "Considerando as relações de coesão referencial no texto sobre a evolução dos equipamentos de combate a incêndio, analise as assertivas a seguir:\n\nI. O pronome relativo \"que\" tem como referente direto o termo antecedente \"regiões\".\nII. O termo anafórico \"Essas novas ferramentas\" sintetiza e retoma as menções a \"bombas de incêndio\" e \"primeira mangueira de combate a incêndio\".\nIII. A especificação \"alcance vertical de até 36 m\" refere-se ao desempenho operacional das \"bombas manuais\" citadas no mesmo período.\n\nQuais estão corretas?";

const ENUNCIADO_NOVO_334 = "Assinale a alternativa que indica uma conjunção que NÃO substitui adequadamente a conjunção coordenativa adversativa \"mas\", por introduzir valor semântico distinto e causar alteração de sentido no período:";

const ENUNCIADO_NOVO_689 = "Considerando a norma ortográfica vigente da Língua Portuguesa, assinale a alternativa que preenche, correta e respectivamente, as lacunas nas seguintes palavras: de...empenho – e...igente – e...gotamento – visuali...ado.";

function body(mode) {
  return `-- ============================================================================
-- FASE 3B-1 — LÍNGUA PORTUGUESA (SANEAMENTO DE REFERÊNCIAS A LINHAS E HIGIENE OCR)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
-- ============================================================================

BEGIN;

-- Garante sessão em leitura e escrita para o harness/apply
SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_enunciado_check text;
  v_divergente record;
  v_hashes_questoes json := '${JSON.stringify(HASH_QUESTAO_ANTES)}';
  v_hashes_explicacoes json := '${JSON.stringify(HASH_EXPLICACAO_ANTES)}';
  v_gabaritos_ordem json := '${JSON.stringify(GABARITO_ORDEM)}';
BEGIN
  -- --------------------------------------------------------------------------
  -- 1. PRECONDIÇÕES E GUARDAS CONTRA DRIFT (ESTADO PRÉ-APPLY)
  -- --------------------------------------------------------------------------

  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Precondição falhou: totais globais divergentes. Esperado 915/907/8, obtido %/%/%',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Validação dos hashes pré-apply das 162 questões de Língua Portuguesa
  SELECT q.id, h.value as esperado,
         md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_questoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão % divergiu do estado auditado (esperado %, obtido %)',
      v_divergente.id, v_divergente.esperado, v_divergente.obtido;
  END IF;

  -- Validação dos hashes pré-apply das 162 explicações de Língua Portuguesa
  SELECT q.id, h.value as esperado,
         md5(replace(q.explicacao, chr(13), '')) as obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_explicacoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(replace(q.explicacao, chr(13), '')) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão % divergiu do estado auditado (esperado %, obtido %)',
      v_divergente.id, v_divergente.esperado, v_divergente.obtido;
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (14 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 66: Enunciado autossuficiente com palavras transcritas
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_66)},
         atualizado_em = now()
   WHERE id = 66;

  -- ID 70: Enunciado autossuficiente com trechos de crase transcritos
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_70)},
         atualizado_em = now()
   WHERE id = 70;

  -- ID 115: Enunciado autossuficiente com trechos de crase da BM 2022
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_115)},
         atualizado_em = now()
   WHERE id = 115;

  -- ID 119: Enunciado autossuficiente de ortografia
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_119)},
         atualizado_em = now()
   WHERE id = 119;

  -- ID 120: Enunciado autossuficiente de regência e pronomes relativos
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_120)},
         atualizado_em = now()
   WHERE id = 120;

  -- ID 121: Enunciado conceitual de conectivos sem referências cegas a linhas
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_121)},
         atualizado_em = now()
   WHERE id = 121;

  -- ID 321: Padronização tipográfica das lacunas ortográficas
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_321)},
         atualizado_em = now()
   WHERE id = 321;

  -- ID 324: Enunciado de coesão referencial autossuficiente
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_324)},
         atualizado_em = now()
   WHERE id = 324;

  -- ID 328: Enunciado autossuficiente com trechos de crase do CBMRS 2025
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_328)},
         atualizado_em = now()
   WHERE id = 328;

  -- ID 329: Enunciado autossuficiente com palavras de ortografia do CBMRS 2025
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_329)},
         atualizado_em = now()
   WHERE id = 329;

  -- ID 330: Higiene de OCR e linha única limpa (e...tremidades)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_330)},
         atualizado_em = now()
   WHERE id = 330;

  -- ID 333: Enunciado de coesão referencial limpo e autossuficiente
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_333)},
         atualizado_em = now()
   WHERE id = 333;

  -- ID 334: Enunciado autossuficiente para substituição da adversativa 'mas'
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_334)},
         atualizado_em = now()
   WHERE id = 334;

  -- ID 689: Padronização das lacunas ortográficas
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_689)},
         atualizado_em = now()
   WHERE id = 689;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados (915 total / 907 ativas / 8 inativas)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (todas as 162 questões de Português ativas)
  IF (SELECT count(*) FROM public.questoes WHERE materia_id = 6 AND ativa = true) <> 162 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões de Língua Portuguesa tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão em todo o universo das 162 questões de Português
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas a JOIN public.questoes q ON q.id = a.questao_id WHERE q.materia_id = 6) <> 162 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas a
         JOIN public.questoes q ON q.id = a.questao_id
        WHERE q.materia_id = 6
        GROUP BY a.questao_id
       HAVING count(*) FILTER (WHERE a.correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões de Língua Portuguesa não possuem exatamente 1 alternativa correta';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos específicos em cada uma das 162 questões
  SELECT h.key::integer as questao_id, h.value::integer as ordem_esperada
    INTO v_divergente
    FROM json_each_text(v_gabaritos_ordem) h
   WHERE NOT EXISTS (
     SELECT 1
       FROM public.alternativas a
      WHERE a.questao_id = h.key::integer
        AND a.ordem = h.value::integer
        AND a.correta = true
   )
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão % de Língua Portuguesa', v_divergente.questao_id;
  END IF;

  -- Assert 5: 148 questões intocadas mantiveram seus hashes integrais
  SELECT q.id, h.value as hash_esperado,
         md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_questoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE q.id NOT IN (66, 70, 115, 119, 120, 121, 321, 324, 328, 329, 330, 333, 334, 689)
     AND md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão % (intocada) foi modificada indevidamente', v_divergente.id;
  END IF;

  -- Assert 6: Explicações de todas as 162 questões de Língua Portuguesa preservadas byte a byte
  SELECT q.id, h.value as hash_esperado,
         md5(replace(q.explicacao, chr(13), '')) as hash_obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_explicacoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(replace(q.explicacao, chr(13), '')) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão % foi alterada indevidamente', v_divergente.id;
  END IF;

  -- Assert 7: Validações específicas de conteúdo higienizado
  -- ID 66: Palavras cora...em / ameni...ar / fa...cínio presentes
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 66;
  IF v_enunciado_check NOT ILIKE '%cora...em%' OR v_enunciado_check NOT ILIKE '%ameni...ar%' OR v_enunciado_check NOT ILIKE '%fa...cínio%' THEN
    RAISE EXCEPTION 'Assert 7a falhou: enunciado da questão 66 não contém as palavras transcritas';
  END IF;

  -- ID 70: Trechos de crase presentes
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 70;
  IF v_enunciado_check NOT ILIKE '%margens da lagoa%' OR v_enunciado_check NOT ILIKE '%tona a discussão%' THEN
    RAISE EXCEPTION 'Assert 7b falhou: enunciado da questão 70 não contém os trechos de crase';
  END IF;

  -- ID 115: Trechos de crase da BM 2022 presentes
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 115;
  IF v_enunciado_check NOT ILIKE '%em relação _____ juventude%' OR v_enunciado_check NOT ILIKE '%resistência _____ mudanças%' THEN
    RAISE EXCEPTION 'Assert 7c falhou: enunciado da questão 115 não contém os trechos transcritos';
  END IF;

  -- ID 119: Comando direto de ortografia
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 119;
  IF v_enunciado_check NOT ILIKE '%norma ortográfica vigente%' THEN
    RAISE EXCEPTION 'Assert 7d falhou: enunciado da questão 119 não foi atualizado corretamente';
  END IF;

  -- ID 120: Trechos de regência e pronomes relativos
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 120;
  IF v_enunciado_check NOT ILIKE '%o cenário _____ nos encontramos%' OR v_enunciado_check NOT ILIKE '%o autor _____ obra foi citada%' THEN
    RAISE EXCEPTION 'Assert 7e falhou: enunciado da questão 120 não contém os trechos transcritos';
  END IF;

  -- ID 121: Conectivos sem menção cega de linha
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 121;
  IF v_enunciado_check NOT ILIKE '%conquanto%' OR v_enunciado_check ILIKE '%Na linha 22%' THEN
    RAISE EXCEPTION 'Assert 7f falhou: enunciado da questão 121 ainda contém referências cegas a linhas';
  END IF;

  -- ID 328: Trechos de crase do CBMRS presentes
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 328;
  IF v_enunciado_check NOT ILIKE '%adaptadas _____ novas necessidades%' OR v_enunciado_check NOT ILIKE '%bombas manuais%' THEN
    RAISE EXCEPTION 'Assert 7g falhou: enunciado da questão 328 não contém os trechos transcritos';
  END IF;

  -- ID 329: Palavras dei...ar / extin...ão / utili...ar presentes
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 329;
  IF v_enunciado_check NOT ILIKE '%dei...ar%' OR v_enunciado_check NOT ILIKE '%extin...ão%' OR v_enunciado_check NOT ILIKE '%utili...ar%' THEN
    RAISE EXCEPTION 'Assert 7h falhou: enunciado da questão 329 não contém as palavras transcritas';
  END IF;

  -- ID 330: Sem 'l. 1 5' e sem 'e...tremidades' com quebra
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 330;
  IF v_enunciado_check ILIKE '%l. 1 5%' OR position(E'\\n' in v_enunciado_check) > 0 THEN
    RAISE EXCEPTION 'Assert 7i falhou: enunciado da questão 330 ainda contém ruído de OCR ou quebra de linha';
  END IF;

  -- ID 334: Substituição da adversativa mas
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 334;
  IF v_enunciado_check NOT ILIKE '%conjunção coordenativa adversativa \"mas\"%' OR v_enunciado_check ILIKE '%na linha 07%' THEN
    RAISE EXCEPTION 'Assert 7j falhou: enunciado da questão 334 não foi atualizado corretamente';
  END IF;

  -- Assert 8: Ausência de quebras literais de barra invertida em enunciados do escopo
  IF (SELECT count(*) FROM public.questoes WHERE id IN (66, 70, 115, 119, 120, 121, 321, 324, 328, 329, 330, 333, 334, 689) AND position('\\n' in enunciado) > 0) > 0 THEN
    RAISE EXCEPTION 'Assert 8 falhou: sequência literal \\n detectada em enunciados tratados';
  END IF;

  RAISE NOTICE 'TODOS OS 8 ASSERTS DA FASE 3B-1 (PORTUGUÊS) PASSARAM COM SUCESSO!';
END $$;

${mode === 'rollback' ? 'ROLLBACK;' : 'COMMIT;'}`;
}

const harnessSql = body('rollback');
const applySql = body('apply');

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Arquivos da Fase 3B-1 gerados com sucesso:`);
console.log(` - ${HARNESS_OUT_PATH}`);
console.log(` - ${APPLY_OUT_PATH}`);
