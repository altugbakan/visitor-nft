// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../Visitor.sol";

contract VisitorTest is Test {
    Visitor visitor;

    function setUp() public {
        visitor = new Visitor();
    }

    function testMint() public {
        vm.store(address(visitor), bytes32(uint256(6)), bytes32(uint256(1))); // _tokenId = 1;
        vm.startPrank(address(1));

        assertEq(visitor.currentTokenId(), 1);
        assertEq(visitor.balanceOf(address(1)), 0);

        vm.expectRevert(Visitor.InvalidToken.selector);
        visitor.tokenOf(address(1));

        visitor.mint();

        assertEq(visitor.currentTokenId(), 2);
        assertEq(visitor.balanceOf(address(1)), 1);
        assertEq(visitor.tokenOf(address(1)), 1);
        vm.stopPrank();
    }

    function testCannotMintTwice() public {
        vm.startPrank(address(2));

        visitor.mint();

        vm.expectRevert(Visitor.AlreadyMinted.selector);
        visitor.mint();

        vm.stopPrank();
    }

    function testCanBurn() public {
        vm.startPrank(address(3));
        uint256 tokenId = visitor.currentTokenId();

        visitor.mint();

        assertEq(visitor.balanceOf(address(3)), 1);
        assertEq(visitor.ownerOf(tokenId), address(3));
        assertTrue( // check tokenURI is not ""
            keccak256(abi.encode(visitor.tokenURI(tokenId))) !=
                keccak256(abi.encode(string("")))
        );

        visitor.burn();

        assertEq(visitor.balanceOf(address(3)), 0);

        vm.expectRevert(Visitor.InvalidOwner.selector);
        visitor.ownerOf(tokenId);

        assertEq(visitor.tokenURI(tokenId), "");
    }
}
