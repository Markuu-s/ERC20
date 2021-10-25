import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {ethers, network} from 'hardhat'
import {expect, assert} from 'chai'

import BigNumber from 'bignumber.js'

BigNumber.config({EXPONENTIAL_AT: 60})

import Web3 from 'web3'
// @ts-ignore
const web3 = new Web3(network.provider) as Web3

import {ERC20} from '../typechain'
import exp from "constants";
let token0: ERC20

class GlobalVariableOfContract {
    owner: SignerWithAddress
    burner: SignerWithAddress
    minter: SignerWithAddress
    name: string
    symbol: string
    decimals: number
    totalSupply: number

    constructor(
        _owner: SignerWithAddress,
        _burner: SignerWithAddress,
        _minter: SignerWithAddress,
        _name: string,
        _symbol: string,
        _decimals: number,
        _totalSupply: number) {
        this.owner = _owner
        this.burner = _burner
        this.minter = _minter
        this.name = _name
        this.symbol = _symbol
        this.decimals = _decimals
        this.totalSupply = _totalSupply
    }
}

let data: GlobalVariableOfContract

beforeEach(async () => {
    let [owner, burner, minter] = await ethers.getSigners()

    data = new GlobalVariableOfContract(owner, burner, minter, "Banana", "BNN", 18, Math.pow(10, 15))

    let ERC20 = await ethers.getContractFactory('ERC20')
    token0 = await ERC20.deploy(data.name, data.symbol, data.decimals, data.totalSupply, data.burner.address, data.minter.address) as ERC20
})

describe('Contract: ERC20', () => {
    describe('test initial state', () => {
        it('check name, symbol, decimals, totalSupply', async () => {
            const [
                _name,
                _symbol,
                _decimals,
                _totalSupply,
            ] = await Promise.all([
                token0.name(),
                token0.symbol(),
                token0.decimals(),
                token0.totalSupply(),
            ])
            expect(_name).to.equal(data.name)
            expect(_symbol).to.equal(data.symbol)
            expect(_decimals).to.equal(data.decimals)
            expect(_totalSupply).to.equal(data.totalSupply)
        })
    })

    describe('Test mint and burn', () => {
        it('Check function mint', async () => {
            let _value = 1000

            await expect(token0.mint(data.burner.address, _value)).reverted
            await expect(token0.connect(data.burner).mint(data.burner.address, _value)).reverted

            await token0.connect(data.minter).mint(data.burner.address, _value)
            expect(await token0.balanceOf(data.burner.address)).to.equal(_value)
        })

        it("Check function burn", async () => {
            let _value = 1000
            await expect(token0.burn(data.minter.address, _value)).reverted
            await expect(token0.connect(data.minter).burn(data.minter.address, _value)).reverted

            await expect(token0.connect(data.burner).burn(data.minter.address, _value)).reverted
            await token0.connect(data.minter).mint(data.minter.address, _value)
            await token0.connect(data.burner).burn(data.minter.address, _value)
        })
    })

    describe('Check function transfer', () =>{
        it('Check requires', async () => {
            let _value = 1000
            await expect(token0.transfer(data.owner.address, _value)).reverted
            await expect(token0.connect(data.minter).transfer(data.burner.address, _value)).reverted
        })

        it('Check work', async () => {
            let _value = 1000
            let oldBalanceOfOwner = await token0.balanceOf(data.owner.address)
            let oldBalanceOfMinter = await token0.balanceOf(data.minter.address)

            await token0.transfer(data.minter.address, _value)

            let newBalanceOfOwner = await token0.balanceOf(data.owner.address)
            let newBalanceOfMinter = await token0.balanceOf(data.minter.address)

            expect(oldBalanceOfOwner.sub(newBalanceOfOwner)).to.equal(_value)
            expect(newBalanceOfMinter.sub(oldBalanceOfMinter)).to.equal(_value)
        })
    })

})
