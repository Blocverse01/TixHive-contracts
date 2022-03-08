using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using NftTickettingContracts.Contracts.EventFactory.ContractDefinition;

namespace NftTickettingContracts.Contracts.EventFactory
{
    public partial class EventFactoryService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, EventFactoryDeployment eventFactoryDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<EventFactoryDeployment>().SendRequestAndWaitForReceiptAsync(eventFactoryDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, EventFactoryDeployment eventFactoryDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<EventFactoryDeployment>().SendRequestAsync(eventFactoryDeployment);
        }

        public static async Task<EventFactoryService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, EventFactoryDeployment eventFactoryDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, eventFactoryDeployment, cancellationTokenSource);
            return new EventFactoryService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public EventFactoryService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }

        public Task<string> EventsQueryAsync(EventsFunction eventsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EventsFunction, string>(eventsFunction, blockParameter);
        }

        
        public Task<string> EventsQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var eventsFunction = new EventsFunction();
                eventsFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<EventsFunction, string>(eventsFunction, blockParameter);
        }

        public Task<string> OwnerQueryAsync(OwnerFunction ownerFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerFunction, string>(ownerFunction, blockParameter);
        }

        
        public Task<string> OwnerQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerFunction, string>(null, blockParameter);
        }

        public Task<string> AddEventRequestAsync(AddEventFunction addEventFunction)
        {
             return ContractHandler.SendRequestAsync(addEventFunction);
        }

        public Task<TransactionReceipt> AddEventRequestAndWaitForReceiptAsync(AddEventFunction addEventFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(addEventFunction, cancellationToken);
        }

        public Task<string> AddEventRequestAsync(EventData eventData, List<Ticket> tickets)
        {
            var addEventFunction = new AddEventFunction();
                addEventFunction.EventData = eventData;
                addEventFunction.Tickets = tickets;
            
             return ContractHandler.SendRequestAsync(addEventFunction);
        }

        public Task<TransactionReceipt> AddEventRequestAndWaitForReceiptAsync(EventData eventData, List<Ticket> tickets, CancellationTokenSource cancellationToken = null)
        {
            var addEventFunction = new AddEventFunction();
                addEventFunction.EventData = eventData;
                addEventFunction.Tickets = tickets;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(addEventFunction, cancellationToken);
        }
    }
}
