'reach 0.1';



// export const main = Reach.App(() => {
//   const creator = Participant('Creator', {
//     approvalLimit: UInt,
//     donationLimit: UInt,
//     state: UInt,
//     name: UInt, // place holder. figure out how to return Bytes
//     url: Bytes(32),
//     approvalExpiryDate: UInt,
//     donationExpiryDate: UInt,
//     causeAccount: Address
//   });
//   const voter = Participant('Voter', {
//     amount: UInt,
//     assetID: UInt,
//     claim:Fun([], Null)
//   });
//    const checker = Participant('Checker', {
    
//    })
 
//   init();
//   creator.only(() => {
//   const approvalLimit = declassify(interact.approvalLimit)
//   const donationLimit = declassify(interact.donationLimit)
//   const state = declassify(interact.state)
//   const name = declassify(interact.name)
//   const url = declassify(interact.url)
//   const donationExpiryDate = declassify(interact.donationExpiryDate)
//   const approvalExpiryDate = declassify(interact.approvalExpiryDate)
//   const causeAccount = declassify(interact.causeAccount)})

//   creator.publish(approvalLimit, donationLimit,state, name, url, donationExpiryDate, approvalExpiryDate);
//   // checker.set(None) // An address/account. To be determined later
//   const approvals = new Map(UInt)
//  const donations = new Map(UInt)
//   commit();
//   // The second one to publish always attaches
//   voter.only(()=>{
//     const amount =  declassify(interact.amount)
//     const asset =  declassify(interact.assetID)
//   })
//   if (asset == 0){
//     voter.publish().pay(amount)
//     if (donations.has(this)){
//       approvals[this]+=amount
//     } else{
//       donations[this] = amount
//     }
//   } else{
//     voter.publish.pay([amount, asset])
    
//     if (approvals.has(this)){
//       approvals[this]+=amount
//     } else{
//       approvals[this] = amount
//     }
//   }

//   voter.publish();
//   commit();
//   // write your program here
//   //when deadline passes or balance is completed.
//   transfer(donationLimit).to(causeAccount)

//   // use map.forEach() to return modey to voters and donating people
  
//   exit();
// });

const ProjectDetails = Object({
  name:Bytes(32),
  url:Bytes(32),
  approvalLimit: UInt,
  approvalDeadline: UInt,
  donationLimit: UInt,
  donationDeadline: UInt,
  fowardingAccount: Address
  
})
export const main = Reach.App(()=>{
  const creator = Participant('Creator', {
    projectDetails: ProjectDetails
  })

  const voter = API('voter', {
    vote: Fun([UInt],Bool),
    claimFunds: Fun([], Bool)
  })

  const donator = API('donator', {
    donate: Fun([UInt], Bool),
    reclaimDonations: Fun([], Bool)
  })
  init();

  creator.only(()=>{
    const projectDetails = declassify(interact.projectDetails)
  })
  creator.publish(projectDetails);
  const {
  name,
  url,
  approvalLimit,
  approvalDeadline,
  donationLimit,
  donationDeadline,
  fowardingAccount
   } = projectDetails
  const voters_list = new Map(Address,UInt);
  const donators = new Map(Address,UInt);

  const refundLoop = (storeMap, asa_id) =>{
    // var passed_count = 0;
    // invariant(passed_count<=Map.size(storeMap));
    // while(passed_count<=Map.size(storeMap)) {
    if(asa_id!=0){
      // storeMap.forEach((_address)=>transfer(storeMap[_address]).to(_address))
      // change to transfer asset when deploying to testnet
    }else{
      // storeMap.forEach((address)=>transfer(storeMap[_address]).to(_address))
    }
    // passed_count+=1
  // }
  }
  const  [votesBalance, keepGoing] = 
  parallelReduce([balance(), true])
    .invariant(balance()>=0)
    .while(votesBalance<approvalLimit && keepGoing)
    .api(voter.vote, 
      ((amount) => assume(amount>0)),
      ((amount) =>  amount ),
      ((amount,setResponse) => {
        if (voters_list[this]){
          const new_balance = fromSome(voters_list[this],0) + amount
          voters_list[this] = new_balance
        } else{
          voters_list[this]=amount
        }
        setResponse(true)
        return [votesBalance+amount,true]
      }))

     .timeout(relativeSecs(approvalDeadline), () => {
       Anybody.publish()
       refundLoop(voters_list, 123456)
       return [votesBalance, false]
      }) // change second parameter to choice Id
     

     const [donationsBalance, GoingOn] = 
     parallelReduce([balance(), true])
       .invariant(balance()>=0)
       .while(donationsBalance<donationLimit)
       .api(donator.donate,
        ((amount)=> {assume(amount>0)}),
        ((amount)=> amount ),
        ((amount, setResponse) => {
          //isSome(this)
          if (donators[this]){
              const new_donators_balance = fromSome(voters_list[this],0) + amount
              donators[this] = new_donators_balance
          } else {
            donators[this]=amount
          }
          setResponse(true)
          if (balance()>=donationLimit){
            transfer(balance()).to(fowardingAccount)
          }
        return [donationsBalance+amount, true]})
        )
        .timeout(relativeSecs(donationDeadline), () => {
          Anybody.publish()
          refundLoop(donators, 0)
          return[donationsBalance, false]
          
        });
        // transfer(balance).to(creator)
        commit();
  exit();
})





// voting Timeout parallel reduce
// const [voters_remaining] =
// parallelReduce([ voters.size() ]) // Voters map length
//   .invariant(0==0)
//   .while(voters_remaining>0)
//  // find a way to loop over the map and send to all to avoid using a timeout
//    .api(voter.claimFunds,
//      (() => {assume(voters_list[this])}),
//      (()=> pass),
//      ((setResponse) => {transfer(fromSome(voters_list[this],0 )).to(this)
//        setResponse(True)
//              }))

// Donation Timeout parallel reduce
// const donators_remaining =
// parallelReduce( donators.size() ) // Voters map length
//   .invariant(0==0)
//   .while(donators_remaining>0)
//  // find a way to loop over the map and send to all to avoid using a timeout
//    .api(donator.reclaimDonations,
//      (() => {assume(donators.has(this))}),
//      (()=> pass),
//      ((setResponse) => {transfer(donators[this]).to(this)
//              setResponse(true)
//              }))