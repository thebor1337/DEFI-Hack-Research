// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }
}

interface IGovernanceFacet {
    function propose(
        IDiamondCut.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        uint8 _pauseOrUnpause
    ) external;

    function balanceOfRoots(address _account) external view returns (uint256);
}
