using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace NftTickettingContracts.Contracts.EventFactory.ContractDefinition
{
    public partial class EventData : EventDataBase { }

    public class EventDataBase 
    {
        [Parameter("string", "name", 1)]
        public virtual string Name { get; set; }
        [Parameter("string", "ticker", 2)]
        public virtual string Ticker { get; set; }
        [Parameter("string", "host_name", 3)]
        public virtual string Host_name { get; set; }
        [Parameter("uint256", "networkId", 4)]
        public virtual BigInteger NetworkId { get; set; }
        [Parameter("uint256", "event_time", 5)]
        public virtual BigInteger Event_time { get; set; }
        [Parameter("string", "category", 6)]
        public virtual string Category { get; set; }
        [Parameter("string", "description", 7)]
        public virtual string Description { get; set; }
        [Parameter("string", "visibility", 8)]
        public virtual string Visibility { get; set; }
        [Parameter("string", "cover_image_url", 9)]
        public virtual string Cover_image_url { get; set; }
    }
}
