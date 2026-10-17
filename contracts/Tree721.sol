//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Tree721 is ERC721URIStorage, Ownable {
    bytes constant private lsdata = bytes('FF+[+F-F-F]-[-F+F+F]FF+[+F-F-F]-[-F+F+F]+[+FF+[+F-F-F]-[-F+F+F]-FF+[+F-F-F]-[-F+F+F]-FF+[+F-F-F]-[-F+F+F]]-[-FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]]+-[-FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]]+[-FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]+FF+[+F-F-F]-[-F+F+F]]'); 
      
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private _ngo_address = 0xA59B29d7dbC9794d1e7f45123C48b2b8d0a34636;
    bool sell_enabled = false;

    event WithdrawEvent(address to, uint256 amount, bool success);
    event NGOUpdatedEvent(address ngo);

    uint256 constant private ngo_percentage = 20;

    struct SVGD {
        uint256 br;
        uint256 bg;
        uint256 bb;
        uint256 sx;
        uint256 sy;
        uint256 sr;
        uint256 cx;
        uint256 cy;
        uint256 er;
        uint256 eg;
    }

    struct TD {
        int x;
        int y;
        int a;
    }

    constructor() ERC721("Tree721", "T721") {
    }

    function enable_sell() public onlyOwner {
        sell_enabled = true;
    }

    function disable_sell() public onlyOwner {
        sell_enabled = false;
    }

    function set_ngo_address(address ngo_address) public payable onlyOwner {
        _ngo_address = ngo_address;
        emit NGOUpdatedEvent(_ngo_address);
    }

    function get_ngo_address() public view returns(address) {
        return _ngo_address;
    }

    function counter() public view returns (uint256) {
        return _tokenIds.current();
    }

    function current_balance() public view returns (uint256) {
        return address(this).balance;
    }

    function purchase_tree() public payable returns (uint256) {
        require(sell_enabled, "Sell is not enabled");
        require(_tokenIds.current() <= 9999, "Maximum of 10k trees");
        uint256 newItemId = _tokenIds.current();

        uint256 minimum_paying_amount = (newItemId + 1) * 0.00005 ether;

        uint256 amount_paid = msg.value;
        require (amount_paid >= minimum_paying_amount, "Amount below minimum amount for tree index");
        
        string memory tokenURI = string(abi.encodePacked("https://storage.googleapis.com/nfttree-default-bucket/jsons/tree-", Strings.toString(newItemId), '.json'));
      
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();

        return newItemId;
    }

    function get_tree(uint256 token_id) external pure returns (string memory svg) {
        require(token_id <= 9999, "Token Id must be >= 0 & <= 9999");

        SVGD memory d;
        d.br = 50 + token_id % 250;
        d.bg = 255 - (200 + token_id + 1) % 200;
        d.bb = 255 - (100 + token_id + 2) % 200;
        d.sx = 10 + ((token_id) % 200);
        d.sy = 10 + ((token_id) % 100);
        d.sr = 10 + ((token_id) % 20);
        d.cx = 10 + (token_id % 240);
        d.cy = 10 + (token_id % 15);
        d.er = 140 + (token_id % 40);
        d.eg = 90 + (token_id % 30);

        string memory svg_header = '<svg height="256" width="256" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';
        svg = string(abi.encodePacked(svg_header));
        string memory defs = '<defs><filter id="b1"><feGaussianBlur stdDeviation="5"/></filter><filter id="b2"><feGaussianBlur stdDeviation="2"/></filter></defs>';
        svg = string(abi.encodePacked(svg, defs));
        // backgrounf
        svg = string(abi.encodePacked(svg, '<rect width="256" height="256" style="fill:rgb(', S(d.br), ',', S(d.bg), ',', S(d.bb), ')"/>'));
        // sun
        svg = string(abi.encodePacked(svg, '<circle cx="',S(d.sx), '" cy="', S(d.sy), '" r="', S(d.sr), '" stroke="none" stroke-width="3" fill="#FDB813" filter="url(#b1)"/>'));
        // cloud
        svg = string(abi.encodePacked(svg, '<path transform="translate(',S(d.cx),' ',S(d.cy),')" d="M 25,60 a 20,20 1 0,0 0,40 h 50 a 20,20 1 0,0 0,-40 a 10,10 1 0,0 -15,-10 a 15,15 1 0,0 -35,10 z" fill="#d0cccc" fill-opacity="0.7" filter="url(#b2)"/>'));
        // earth
        svg = string(abi.encodePacked(svg, '<path d="M 0 180 C 40 130, 65 100, 95 180 S 150 150, 256 180 L 256, 256 L 0, 256 Z" style="fill:rgb(',S(d.er),',',S(d.eg),',',S(66),')" fill-opacity="1.0" stroke="none"/>'));
        svg = string(abi.encodePacked(svg, '<path d="M 0 180 C 40 130, 65 100, 95 180 S 150 150, 256 180" fill="none" stroke="green"/>'));
        // Birds
        svg = string(abi.encodePacked(svg, '<path transform="translate(28 10)" d="M 50 50 C 60 60, 60 60, 70 50" stroke="black" stroke-width="2" fill="none"/>'));
        svg = string(abi.encodePacked(svg, '<path transform="translate(35 18)" d="M 50 50 C 60 60, 60 60, 70 50" stroke="black" stroke-width="2" fill="none"/>'));
        svg = string(abi.encodePacked(svg, '<path transform="translate(25 15)" d="M 50 50 C 60 60, 60 60, 70 50" stroke="black" stroke-width="2" fill="none"/>'));
        
        // Tree
        string memory tree_data = tree(token_id);
        svg = string(abi.encodePacked(svg, tree_data));
         
        // End SVG
        svg = string(abi.encodePacked(svg, '<text x="5" y="245">', S(token_id), '/mainnet https://yournftree.com/</text>'));
        svg = string(abi.encodePacked(svg, '</svg>'));
    }

    function tree(uint256 token_id) internal pure returns (string memory) {
        int x2;
        int y2;
        int x = 128;
        int y = 256;
        int nalpha;
        if (token_id % 2 == 0) {
            nalpha = 25;
        } else {
            nalpha = 35;
        }
        int a = 0;

        TD[] memory tds = new TD[](5);
        uint256 tds_i = 0;

        string memory tree_svg = string(abi.encodePacked(''));
        for(uint i = 0; i < lsdata.length; i++) {
            bytes1 e = lsdata[i];
            if (e == bytes1('F')) {
                x2 = x + 16 * sin(a) / 100;
                y2 = y - 16 * cos(a) / 100;

                tree_svg = string(abi.encodePacked(tree_svg,'<line x1="',S2(x),'" y1="',S2(y),'" x2="',S2(x2),'" y2="',S2(y2),'" style="stroke:rgb(252, 201, 185);stroke-width:5" />'));

                x = x2;
                y = y2;
            } else if (e == bytes1('+')) {
                a = a + nalpha;
            } else if (e == bytes1('-')) {
                a = a - nalpha;
            } else if (e == bytes1('[')) {
                TD memory saved_td;
                saved_td.x = x;
                saved_td.y = y;
                saved_td.a = a;
                tds[tds_i] = saved_td;
                tds_i = tds_i + 1;
            } else if (e == bytes1(']')) {
                tds_i = tds_i - 1;
                TD memory saved_td = tds[tds_i];
                x = saved_td.x;
                y = saved_td.y;
                a = saved_td.a;
            }
        } // for all ls data

        return tree_svg;
    }

    function S(uint256 value) internal pure returns (string memory) {
        return Strings.toString(value);
    }

    function S2(int i) internal pure returns (string memory) {
        bool negative = i < 0;
        uint256 value;
        if (negative) {
            value = uint256(i * -1);
        } else {
            value = uint256(i);
        }
        return Strings.toString(value);
    }

        function cos(int a) public pure returns (int) {
        if (a == 0) return 100;
        else if (a == -35) return 81;
        else if (a == 35) return 81;
        else if (a == 100) return -17;
        else if (a == -70) return 34;
        else if (a == 70) return 34;
        else if (a == 105) return -25;
        else if (a == 75) return 25;
        else if (a == 140) return -76;
        else if (a == -50) return 64;
        else if (a == 50) return 64;
        else if (a == -25) return 90;
        else if (a == 25) return 90;
        else return 0;  
    }

    function sin(int a) public pure returns (int) {
        if (a == 0) return 0;
        else if (a == -35) return -57;
        else if (a == 35) return 57;
        else if (a == 100) return 98;
        else if (a == -70) return -93;
        else if (a == 70) return 93;
        else if (a == 105) return 96;
        else if (a == 75) return 96;
        else if (a == 140) return 64;
        else if (a == -50) return -76;
        else if (a == 50) return 76;
        else if (a == -25) return -42;
        else if (a == 25) return 42;
        else return 0; 
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ETH left to withdraw");

        uint ngo_amount = balance * ngo_percentage / 100;
        uint owner_amount = balance - ngo_amount;

        // Owner
        (bool success1, ) = (msg.sender).call{value: owner_amount}("");
        emit WithdrawEvent(msg.sender, owner_amount, success1);
        require(success1, "Owner Transfer failed.");

        // NGO
        (bool success2, ) = (_ngo_address).call{value: ngo_amount}("");
        emit WithdrawEvent(_ngo_address, ngo_amount, success2);
        require(success2, "NGO Transfer failed.");
    }
}