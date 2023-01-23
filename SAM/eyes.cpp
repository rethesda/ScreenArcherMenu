#include "eyes.h"

#include "constants.h"
#include "SAF/hacks.h"
#include "sam.h"

void GetEyes(GFxResult& result) {
	float coords[2];
	if (!SAF::GetEyecoords(SAF::GetEyeNode(selected.refr), coords))
		return result.SetError(EYE_ERROR);

	result.CreateValues();
	result.PushValue(&GFxValue(coords[0] * -4));
	result.PushValue(&GFxValue(coords[1] * 5));
}

void SetEyes(GFxResult& result, float x, float y) {
	auto eyeNode = SAF::GetEyeNode(selected.refr);
	if (!eyeNode)
		return result.SetError(EYE_ERROR);

	if (GetDisableEyecoordUpdate() != kHackEnabled)
		SetDisableEyecoordUpdate(true);

	SAF::SetEyecoords(eyeNode, x * -0.25, y * 0.2);
}