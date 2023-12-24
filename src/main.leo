program huseyinLoraAnkaraTokenWorkshop.aleo {
    // mintleyebilmemiz lazım
    // mint: 50 taso yaratmak
    // public ve private state'ler var
    // public or private mint
    mapping account:address => u64;
    // private'lar record'lar ile oluyor

    record token{
      owner: address,
      amount: u64,
    };

    transition mint_public(public receiver:address, public amount:u64){
      // herkese duyurmak için finalize kullanıyruz

      return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver:address, public amount:u64){
      // zincirdeki veriyi kullanan mapping
      let receiver_amount:u64 = Mapping::get_or_use(account,receiver, 0u64);
      Mapping::set(account, receiver, receiver_amount + amount);
    };

    // private by default
    //utxo bitcoinde var.
    // aleodaki recordlar da buna benziyor
    // 100 tane tokenim var

    transition mint_private(receiver:address, amount:u64) -> token {
      return token {
        owner: receiver, 
        amount: amount,
      };
    };

    transition transfer_public(public receiver:address, public amount:u64){
      // self.caller = sender
      return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender:address, public receiver, amount:u64){
      let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64); // 50
      Mapping::set(account, sender, sender_amount - amount); // 30 = 50-20
      let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64); // 50
      Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_private(sender:token, receiver:address, amount:u64) -> (token, token) { 
      let difference:u64 = sender.amount - amount;

      let remaining:token = token {
        owner:sender.owner,
        amount: difference
      };

      let transferred:token = token {
        owner: receiver,
        amount: amount
      };

      return (remaining, transferred);
    }

    transition transfer_private_to_public(sender:token, public receiver:address, public amount:u64)-> token {
      let difference:u64 = sender.amount - amount;

      let remaining:token  = token {
        owner:sender.owner,
        amount:difference
      };

      return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver:address, public amount:u64){
      let receiver_amount:u64= Mapping::get_or_use(account,receiver,0u64);
      Mapping::set(account,receiver , receiver_amount + amount);
    }

    transition transfer_public_to_private(receiver:address, amount:u64) -> token {
      let transferred:token = token {
        owner:receiver,
        amount: amount
      };

      return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender:address, public amount:u64){
      let sender_amount:u64 = Mapping::get_or_use(account,sender, 0u64);
      Mapping::set(account, sender, sender_amount - amount);
    }
}










/* 

type belirtmesi yapılıyor
bool
int: u8 
1 için 1u8 yazıyorsun
her aleo programının unique bir ismi olmalıdır.
program adı yaratırken hata alabilirsin

! struct : objeler
! kayıtlar

zk prooflar private şekilde yönetiliyor
onurun 2 yaşında olduğunu bilmeden 22 yşaında olduğunu kanıtlayabiliyorsun. zknin olayı bu

record (private state'leri tutuyor) vs. struct  
dinamik array yok (size'ını kendi belirleyen array) leo'da
array'ler static tpye'a sahip önceden belirlemen gerekiyor

aleoda 3 farklı function var
transition, 
- içinde işlem yapabildiğin fonksiyonlar
- en sık kullanılan en yüksek fonksiyon tipi
- program scope'unda tanımlanır

helper function da var
program scope'unun dışında çağrılır
transition tarafından tetiklenmesi gerekiyopr

inline-function da helper function tarafından çağrılması gerekiyor
inline'lar sadece inline'ları çağırabiliyor

finalize'da 'şunu şuna gönderdim' diyebiliyoruz.
zincir üzerinde state değiştiren şeyler finalize 



 */