import { Crush, readBoolean, readDate } from "./base";
import { UserPlaylogItem } from "../model/userPlaylog";

export type UserPlaylogJson = Crush<UserPlaylogItem>;

export function readUserPlaylog(json: UserPlaylogJson): UserPlaylogItem {
  return {
    orderId: parseInt(json.orderId),
    sortNumber: parseInt(json.sortNumber),
    placeId: parseInt(json.placeId),
    playDate: readDate(json.playDate),
    userPlayDate: readDate(json.userPlayDate),
    musicId: parseInt(json.musicId),
    level: parseInt(json.level),
    customId: parseInt(json.customId),
    playedUserId1: parseInt(json.playedUserId1),
    playedUserId2: parseInt(json.playedUserId2),
    playedUserId3: parseInt(json.playedUserId3),
    playedUserName1: json.playedUserName1,
    playedUserName2: json.playedUserName2,
    playedUserName3: json.playedUserName3,
    playedMusicLevel1: parseInt(json.playedMusicLevel1),
    playedMusicLevel2: parseInt(json.playedMusicLevel2),
    playedMusicLevel3: parseInt(json.playedMusicLevel3),
    playedCustom1: parseInt(json.playedCustom1),
    playedCustom2: parseInt(json.playedCustom2),
    playedCustom3: parseInt(json.playedCustom3),
    track: parseInt(json.track),
    score: parseInt(json.score),
    rank: parseInt(json.rank),
    maxCombo: parseInt(json.maxCombo),
    maxChain: parseInt(json.maxChain),
    rateTap: parseInt(json.rateTap),
    rateHold: parseInt(json.rateHold),
    rateSlide: parseInt(json.rateSlide),
    rateAir: parseInt(json.rateAir),
    rateFlick: parseInt(json.rateFlick),
    judgeGuilty: parseInt(json.judgeGuilty),
    judgeAttack: parseInt(json.judgeAttack),
    judgeJustice: parseInt(json.judgeJustice),
    judgeCritical: parseInt(json.judgeCritical),
    eventId: parseInt(json.eventId),
    playerRating: parseInt(json.playerRating),
    isNewRecord: readBoolean(json.isNewRecord),
    isFullCombo: readBoolean(json.isFullCombo),
    fullChainKind: parseInt(json.fullChainKind),
    isAllJustice: readBoolean(json.isAllJustice),
    isContinue: readBoolean(json.isContinue),
    isFreeToPlay: readBoolean(json.isFreeToPlay),
    characterId: parseInt(json.characterId),
    skillId: parseInt(json.skillId),
    playKind: parseInt(json.playKind),
    isClear: readBoolean(json.isClear),
    skillLevel: parseInt(json.skillLevel),
    skillEffect: parseInt(json.skillEffect),
    placeName: json.placeName,
    isMaimai: readBoolean(json.isMaimai),
  };
}
