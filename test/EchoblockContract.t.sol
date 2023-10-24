// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/EchoblockContract.sol";

contract EchoBlockMusicTest is Test {
    EchoBlockMusic public echoBlockMusic;
    address public artist;

    function setUp() public {
        artist = address(0x123);
        echoBlockMusic = new EchoBlockMusic();

        echoBlockMusic.grantRole(keccak256("ARTIST_ROLE"), artist);
    }

    function testCreateSong() public {
        vm.startPrank(artist);

        string memory metadataUri = "https://example.com/metadata/1";
        uint256 totalTokens = 100;
        uint256 percentageForSale = 40;

        console.log("Creating song with the following parameters:");
        console.log("Metadata URI:", metadataUri);
        console.log("Total Tokens:", totalTokens);
        console.log("Percentage for Sale:", percentageForSale);

        echoBlockMusic.createSong(metadataUri, totalTokens, percentageForSale);

        uint256 tokensForArtist = totalTokens -
            (totalTokens * percentageForSale) /
            100;
        uint256 tokensForSale = (totalTokens * percentageForSale) / 100;

        console.log("Checking balances and URI...");
        console.log("Expected tokens for artist:", tokensForArtist);
        console.log(
            "Actual tokens for artist:",
            echoBlockMusic.balanceOf(artist, 0)
        );

        console.log("Expected tokens for sale:", tokensForSale);
        console.log(
            "Actual tokens for sale:",
            echoBlockMusic.balanceOf(address(echoBlockMusic), 0)
        );

        console.log("Expected URI:", metadataUri);
        console.log("Actual URI:", echoBlockMusic.uri(0));

        assertEq(echoBlockMusic.balanceOf(artist, 0), tokensForArtist);
        assertEq(
            echoBlockMusic.balanceOf(address(echoBlockMusic), 0),
            tokensForSale
        );
        assertEq(echoBlockMusic.uri(0), metadataUri);

        vm.stopPrank();
    }
}
