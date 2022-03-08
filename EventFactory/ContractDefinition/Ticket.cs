using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace NftTickettingContracts.Contracts.EventFactory.ContractDefinition
{
    public partial class Ticket : TicketBase { }

    public class TicketBase 
    {
        [Parameter("string", "name", 1)]
        public virtual string Name { get; set; }
        [Parameter("string", "description", 2)]
        public virtual string Description { get; set; }
        [Parameter("string", "ticket_type", 3)]
        public virtual string Ticket_type { get; set; }
        [Parameter("uint256", "quantity_available", 4)]
        public virtual BigInteger Quantity_available { get; set; }
        [Parameter("uint256", "max_per_order", 5)]
        public virtual BigInteger Max_per_order { get; set; }
        [Parameter("uint256", "price", 6)]
        public virtual BigInteger Price { get; set; }
    }
}
