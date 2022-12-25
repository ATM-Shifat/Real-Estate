export type ESTATE = {
  id: string;
  // Owner of property, if property is listed for sale, this will be the seller address
  owner: string;
  // If price > 0, the property is for sale
  price: string;
  tokenURI: string;
};
